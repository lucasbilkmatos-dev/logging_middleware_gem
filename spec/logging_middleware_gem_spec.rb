require 'spec_helper'

RSpec.describe LoggingMiddlewareGem::Middleware, type: :middleware do
  let(:mock_user) do
    double('User', id: 1, name: 'Test User', email: 'testuser@example.com')
  end
  let(:warden) { double('Warden', user: mock_user) }
  let(:app) { ->(env) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] } }
  let(:middleware) { described_class.new(app) }
  let(:env) do
    # Mock the Warden user and add it to the environment
    Rack::MockRequest.env_for('/some_path', 'REQUEST_METHOD' => 'GET', 'warden' => warden)
  end

  before do
    allow_any_instance_of(LoggingMiddlewareGem::Middleware).to receive(:save_log_data_to_mongo)
    Flipper.enable(:logging_middleware)
    Thread.current[:test] = true
  end

  before :each do
    # Reset any thread-local variables
    Thread.current[:log_data] = {
      request: {},
      user: {},
      response: {}
    }
    Thread.current[:enable_logging] = true
  end

  after :each do
    Thread.current[:log_data] = nil
    Thread.current[:enable_logging] = nil
  end

  it 'calls the app and logs the request and response' do
    middleware.call(env)

    log_data = Thread.current[:log_data]

    expect(log_data).not_to be_nil
    expect(log_data[:request][:route]).to eq('/some_path')
    expect(log_data[:response][:status]).to eq(200)
  end

  it 'logs request and response data' do
    middleware.call(env)

    log_data = Thread.current[:log_data]

    expect(log_data[:request]).to include(
                                    http_verb: 'GET',
                                    route: '/some_path'
                                  )
    expect(log_data[:response][:status]).to eq(200)
  end

  it 'removes unwanted headers from the logs' do
    env_with_headers = Rack::MockRequest.env_for('/some_path',
                                                 'HTTP_SOME_HEADER' => 'value',
                                                 'HTTP_AUTHORIZATION' => 'secret',
                                                 'warden' => warden
    )
    middleware.call(env_with_headers)

    log_data = Thread.current[:log_data]

    expect(log_data[:request][:headers]).not_to include('authorization')
  end
end
