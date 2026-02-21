require_relative "lib/rails2static/version"

Gem::Specification.new do |spec|
  spec.name = "rails2static"
  spec.version = Rails2static::VERSION
  spec.authors = ["Ian"]
  spec.summary = "Generate a static site from a Rails app"
  spec.description = "Crawls a server-rendered Rails app via Rack::Test and outputs a deployable static site."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir["lib/**/*", "LICENSE", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rack-test", "~> 2.0"
  spec.add_dependency "nokogiri", "~> 1.15"

  spec.add_development_dependency "rspec", "~> 3.12"
end
