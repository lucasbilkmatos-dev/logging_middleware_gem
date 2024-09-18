module LoggingMiddlewareGem
  class Middleware
    SENSITIVE_PARAMS = %w[authenticity_token password token].freeze
    SENSITIVE_HEADERS = %w[request_method request_path authorization cookie set-cookie www-authenticate location refresh x-forwarded-for via forwarded script_name query_string gateway_interface request_uri path_info remote_addr routes_17060_script_name original_fullpath original_script_name rack_mini_profiler_original_script_name link referrer-policy content-type charset vary etag cache-control routes_19900_script_name].freeze

    attr_reader :env, :request, :user, :log_data, :status, :headers, :response

    def initialize(app)
      @app = app
    end

    def call(env)
      call_app(env)
      initialize_request_log

      return middleware_response unless Flipper.enabled?(:logging_middleware)
      return middleware_response unless Thread.current[:enable_logging]

      return middleware_response if request.path == '/health'
      return middleware_response if user.blank?

      build_request_log
      build_request_params_log
      build_request_headers_log
      build_user_log
      build_response_headers_log

      save_log_data_to_mongo

      middleware_response
    rescue StandardError => e
      Rails.logger.error("Error in LoggingMiddlewareGem: #{e.message}")

      raise e

      middleware_response
    ensure
      # Clean up the thread-local variables
      unless Thread.current[:test]
        Thread.current[:log_data] = nil
        Thread.current[:enable_logging] = nil
      end
    end

    private

    def call_app(env)
      @env = env
      @status, @headers, @response = @app.call(env)
    end

    def middleware_response
      [status, headers, response]
    end

    def initialize_request_log
      @request = ActionDispatch::Request.new(env)
      @user = request.env['warden']&.user
      @log_data = Thread.current[:log_data] ||= {
        http: {},
        user: {},
        payload: {}
      }
    end

    def build_request_log
      log_data[:http][:request] = {}
      log_data[:http][:request][:http_verb] = request.request_method
      log_data[:http][:request][:route] = request.fullpath
      log_data[:http][:request][:user_agent] = request.user_agent
      log_data[:http][:request][:remote_ip] = request.remote_ip
      log_data[:http][:request][:url] = request.original_url
      log_data[:http][:request][:request_id] = request.uuid
    end

    def build_request_params_log
      log_data[:http][:request][:query_params] = sanitize_params(request.query_parameters)
      log_data[:http][:request][:request_params] = sanitize_params(request.request_parameters)
    end

    def build_request_headers_log
      log_data[:http][:request][:headers] = sanitize_headers(request.headers.to_h)
    end

    def build_user_log
      log_data[:user][:email] = user.email
      log_data[:user][:user_id] = user.id
    end

    def build_response_headers_log
      log_data[:http][:response] = {}
      log_data[:http][:response][:status] = status
      log_data[:http][:response][:headers] = sanitize_headers(headers)
    end

    def sanitize_params(params)
      params.reject { |key, _value| SENSITIVE_PARAMS.include?(key) }
    end

    def sanitize_headers(headers)
      headers.reject do |key, _value|
        SENSITIVE_HEADERS.include?(key.downcase) ||
          key.downcase.start_with?('rack.', 'puma.', 'action_dispatch.', 'warden', 'http_', 'server', 'action_controller.', 'x-')
      end
    end

    def save_log_data_to_mongo
      log = Models::BackofficeLog.create!(
        http: JSON.parse(log_data[:http].to_json),
        user: JSON.parse(log_data[:user].to_json),
        payload: JSON.parse(log_data[:payload].to_json)
      )

      Rails.logger.info("LogData: #{log_data.to_json}")
      Rails.logger.info("LogEntry created: #{log}")
    end
  end
end
