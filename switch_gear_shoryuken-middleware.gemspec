# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "switch_gear_shoryuken/middleware/version"

Gem::Specification.new do |spec|
  spec.name          = "switch_gear_shoryuken-middleware"
  spec.version       = SwitchGearShoryuken::Middleware::VERSION
  spec.authors       = ["Anthony Ross"]
  spec.email         = ["anthony.s.ross@gmail.com"]

  spec.summary       = %q{Circuit breaker middleware for Shoryuken}
  spec.description   = %q{Circuit breaker middleware for Shoryuken}
  spec.homepage      = "https://github.com/allcentury/switch_gear_shoryuken-middleware"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "shoryuken"
  spec.add_dependency "switch_gear", "~> 0.3"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "aws-sdk-sqs"
  spec.add_development_dependency "redis"
end
