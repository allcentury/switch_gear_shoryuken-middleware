require "switch_gear"
require "switch_gear_shoryuken/middleware/version"
require "switch_gear_shoryuken/breaker"

module SwitchGearShoryuken
  class Middleware
    attr_reader :breakers

    def initialize(breakers:)
      @breakers = breakers.each_with_object({}) do |breaker, hash|
        hash[breaker.worker] = breaker
      end
    end

    def call(worker, queue, sqs_msg, body, &block)
      breaker = breakers[worker.class]

      if !breaker
        Shoryuken.logger.info "No breaker found for #{worker.class}"
        yield
        return
      end

      Shoryuken.logger.info "Breaker being used: #{breaker}"

      breaker.call(block)
    rescue SwitchGear::CircuitBreaker::OpenError
      retry_in = breaker.reset_timeout
      fail_msg = "Circuit is open for worker: #{breaker.worker} - blocking all calls;"
      fail_msg += "  Jobs will try again in: #{retry_in} seconds"
      Shoryuken.logger.warn fail_msg
      # need to think about this more, what if this exceedes visbility_timeout?
      sleep retry_in
    end
  end
end
