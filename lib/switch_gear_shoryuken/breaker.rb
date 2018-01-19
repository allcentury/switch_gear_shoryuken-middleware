module SwitchGearShoryuken
  class Breaker < ::SwitchGear::CircuitBreaker::Redis
    attr_accessor :worker
    def initialize
      yield self
      @namespace = "circuit_breaker_#{worker}"
      @logger = logger || Shoryuken.logger
      # dummy lambda to allow easy invocation of job
      @circuit = circuit || -> (sk_job) { sk_job.call }
      run_validations
    end

    def to_s
      <<-EOF
        [SwitchGearShoryuken::Breaker] - Breaker config
        namespace: #{namespace}
        logger: #{logger}
        circuit: #{circuit}
        reset_timeout: #{reset_timeout}
        failure_limit: #{failure_limit}
      EOF
    end

    private

    def run_validations
      msg = "please provider a worker"
      raise(ArgumentError, msg) if !worker
    end
  end
end
