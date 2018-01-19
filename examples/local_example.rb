# Assumes moto is running
# https://github.com/phstc/shoryuken/wiki/Using-a-local-mock-SQS-server
# run git clone git@github.com:spulec/moto.git
# cd moto
# make init
# moto_server sqs -p 4576
#
# start redis

require 'redis'
require 'logger'
require 'shoryuken'
require 'aws-sdk-sqs'
require 'pry'
require_relative '../lib/switch_gear_shoryuken/middleware'

aws_client = Aws::SQS::Client.new(
    region: ENV["AWS_REGION"] || "us-east-1",
    access_key_id: ENV["AWS_ACCESS_KEY_ID"] || "abc",
    secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"] || "abc",
    endpoint: 'http://localhost:4576',
    verify_checksums: false
  )

# start redis first
redis = Redis.new

module MyModule
  class MyWorker
    include Shoryuken::Worker

    shoryuken_options queue: 'my_queue', auto_delete: true

    def perform(sqs_msg, arg)
      fail "boom"
      p sqs_msg
      p arg
    end
  end
end

breaker = SwitchGearShoryuken::Breaker.new do |b|
  b.client = redis
  b.worker = MyModule::MyWorker
  b.failure_limit = 2
  b.reset_timeout = 10
  b.logger = Logger.new(STDOUT)
  b.circuit = ->(job_block) { job_block.call }
end

Shoryuken.configure_client do |config|
  config.sqs_client = aws_client
end

Shoryuken.configure_server do |config|
  config.sqs_client = aws_client
  config.server_middleware do |chain|
    chain.add SwitchGearShoryuken::Middleware, breakers: [breaker]
  end
end

queue = aws_client.create_queue(queue_name: 'my_queue')
puts queue.queue_url

50.times do
  MyModule::MyWorker.perform_async('test')
end
