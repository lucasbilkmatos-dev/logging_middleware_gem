require "bundler/setup"
require "rack"
require "logging_middleware_gem"
require 'rails'
require 'action_dispatch'
require 'flipper'
require 'pry'
require 'pry-nav'
require 'pry-remote'


RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

Flipper.configure do |config|
  config.adapter { Flipper::Adapters::Memory.new }
end
