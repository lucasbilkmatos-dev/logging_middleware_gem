require "active_support/concern"

module LoggingMiddlewareGem
  module LoggingConcern
    extend ActiveSupport::Concern

    included do
      before_action :initialize_log_data
      before_action :set_logging_flag
    end

    def log_data
      Thread.current[:log_data] ||= {
        http: {},
        user: {},
        payload: {}
      }
    end

    def add_to_log_data(key, value)
      log_data[:payload][key] = value
    end

    private

    def initialize_log_data
      Thread.current[:log_data] ||= {
        request: {},
        user: {},
        response: {}
      }
    end

    def set_logging_flag
      Thread.current[:enable_logging] = true
    end
  end
end
