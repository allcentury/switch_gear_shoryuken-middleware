# SwitchGearShoryuken::Middleware

This gem provides a middleware to use SwitchGear with Shoryuken.  It allows you to specify circuit breakers for each worker class and define its own config.  You can configure it like so:

```ruby
# config/intializers/switch_gear.rb

breaker = SwitchGearShoryuken::Breaker.new do |b|
  b.client = Redis.new || SomeConnectionPool.checkout_redis_client
  b.worker = MyModule::MyWorker
  b.failure_limit = 2 # how many failures before we trip?
  b.reset_timeout = 10 # how long do we idle for?  This value should likely NOT exceed your visability timeout
  b.logger = Rails.logger || Logger.new(STDOUT)
  b.circuit = ->(job_block) { job_block.call } # nothing to do here
end

# add the middleware to Shoryuken
Shoryuken.configure_server do |config|
  config.server_middleware do |chain|
    chain.add SwitchGearShoryuken::Middleware, breakers: [breaker]
  end
end
```

The pattern is basically to create a breaker for every worker you need them for.  You pass an array of breakers to the middleware and that's it.  

If you're wondering how it works, Shoryuken provides the worker class to the middleware which we then use to look up the breaker in a hash.  



## Dependencies

You can run this with SwitchGear's in memory breaker but the examples all use redis.  There is no gem dependency on redis but tested it via redis-rb.  SwitchGear will ensure the right methods exist on your redis client before instantiation.


## Try before you buy
If want to see what this looks like, I've created an [example](examples/local_example.rb).  There are some set up instructions in that file but once set up, you can run:

 `bundle exec shoryuken -q my_queue -r ./examples/local_example.rb`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'switch_gear_shoryuken-middleware'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install switch_gear_shoryuken-middleware

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/switch_gear_shoryuken-middleware. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SwitchGearShoryuken::Middleware project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/switch_gear_shoryuken-middleware/blob/master/CODE_OF_CONDUCT.md).
