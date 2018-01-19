require "spec_helper"

RSpec.describe SwitchGearShoryuken::Middleware do
  let(:redis) { double('redis') }
  let(:worker) { Helpers::SomeWorker.new }
  let(:queue) { "my_queue" }
  let(:msg) { double('sqs msg') }
  let(:body) { double('json body') }
  let(:reset_timeout) { 2 }

  let(:middleware) { described_class.new(breakers: [breaker]) }
  let(:breaker) do
    SwitchGearShoryuken::Breaker.new do |b|
      b.client = redis
      b.worker = Helpers::SomeWorker
      b.failure_limit = 2
      b.reset_timeout = reset_timeout
      b.logger = Logger.new(STDOUT)
      b.circuit = ->(job_block) { job_block.call }
    end
  end

  it "has a version number" do
    expect(SwitchGearShoryuken::Middleware::VERSION).not_to be nil
  end

  it 'supports custom middleware' do
    chain = Shoryuken::Middleware::Chain.new
    chain.add described_class

    expect(chain.entries.last.klass).to be described_class
  end

  describe 'with middlware configured' do
    it 'runs the job normally without error' do
      allow(redis).to receive(:get).with(/state/).and_return("closed")
      allow(redis).to receive(:del)
      expect(redis).to receive(:set).with(/state/, /closed/)
      expect(worker).to_not receive(:perform_in)
      middleware.call(worker, queue, msg, body) do
        p 'running job...'
      end
    end

    it 're-enqueues a job ' do
      allow(redis).to receive(:get).with(/state/).and_return("open")
      expect(breaker).to receive(:check_reset_timeout)
      middleware.call(worker, queue, msg, body) do
        'running job...'
      end
    end
  end
end
