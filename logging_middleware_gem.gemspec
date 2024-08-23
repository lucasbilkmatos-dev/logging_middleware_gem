lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "logging_middleware_gem/version"

Gem::Specification.new do |spec|
  spec.name          = "logging_middleware_gem"
  spec.version       = LoggingMiddlewareGem::VERSION
  spec.authors       = ["Lucas Bilk Matos"]
  spec.email         = ["lucas.matos@vitat.com.br"]

  spec.summary       = %q{A middleware gem for logging requests and responses to MongoDB.}
  spec.description   = %q{A Rails middleware that logs requests, responses, and user details to MongoDB. The gem is designed to be portable and can be used across different projects.}
  spec.homepage      = "https://github.com/lucasbilkmatos/logging_middleware_gem"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 3.1.2'

  # Metadata for RubyGems
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/lucasbilkmatos/logging_middleware_gem"
    spec.metadata["changelog_uri"] = "https://github.com/lucasbilkmatos/logging_middleware_gem/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  # Files to include in the gem
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Add runtime dependencies
  spec.add_dependency "mongo", "~> 2"
  spec.add_dependency "rails", "~> 7.0.8.4"
  spec.add_dependency "mongoid", "~> 7.0"
  spec.add_dependency "flipper", "~> 1.3.0"
  spec.add_dependency "activesupport", "~> 7.0.8.4"
  spec.add_dependency "rack"
  spec.add_dependency "pry-nav"
  spec.add_dependency "pry-remote"
  spec.add_dependency "pry"

  # Add development dependencies
  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "rake", "~> 12.2"
  spec.add_development_dependency "rspec", "~> 3.0"
end
