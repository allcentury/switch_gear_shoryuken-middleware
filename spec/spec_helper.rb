require "bundler/setup"
require "switch_gear_shoryuken/middleware"
require "shoryuken"
require "pry"

module Helpers
  class SomeWorker
    include Shoryuken::Worker
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
