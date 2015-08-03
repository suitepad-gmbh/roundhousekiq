![Jackie Chan](jackie-chan.jpg)

# Roundhousekiq

Small AMQP to Sidekiq bridge, allowing Sidekiq jobs to be triggered via AMQP.
You define your Sidekiq jobs as usual, but instead of manually invoking the
jobs, you define to which AMQP event the worker should listen on.

Take for example our device pings, which are already sent via AMQP and must be
processed by the API. We simply write a worker processing these pings and
specify that the worker should be executed for every message received on the
direct exchange with the routing key `ping`.

```ruby
class DevicePingWorker
  include Sidekiq::Worker
  include Roundhousekiq::Worker

  # AMQP configuration
  exchange_name 'suitepad.server'
  exchange_type :direct
  queue_name    'suitepad.server.pings_v2'
  routing_key   :ping

  # Attributes:
  #   payload: Payload directly from AMQP
  def perform(payload)
    # Heavy computing action...
  end

end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'roundhousekiq'
```

Make sure, you've included the SuitePad gem host or the gem won't be found.

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install roundhousekiq

## Usage

TODO: Write usage instructions here
