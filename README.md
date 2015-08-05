![Chuck Norris](chuck-norris.png)

# Roundhousekiq

![Gem version](https://img.shields.io/gem/v/roundhousekiq.svg?style=flat)
![Build Status](https://img.shields.io/travis/suitepad-gmbh/roundhousekiq.svg?style=flat)
![License MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)
![CC Score](https://img.shields.io/codeclimate/github/suitepad-gmbh/roundhousekiq.svg?style=flat)

Small AMQP to Sidekiq bridge, allowing Sidekiq jobs to be triggered via AMQP.
You define your Sidekiq jobs as usual, but instead of manually invoking the
jobs, you define to which AMQP event the worker should listen on.

Take for example a fleet of services all reporting their current status every
once in a while to your central monitoring service. Because these services do
not care about when their status report is being processed and by whom, they
simple send it via your AMQP server's `status` exchange and let others handle
the rest.

The monitoring service now uses Roundhousekiq to asynchronously process these
status reports and to keep the load from the main server process, it does the
processing in background using Sidekiq. Simply set up a new Sidekiq worker,
specify the AMQP exchange and routing key to listen on, and let Roundhousekiq
handle the AMQP bindings and finding the right worker for each message:

```ruby
class StatusWorker
  include Sidekiq::Worker
  include Roundhousekiq::Worker

  # AMQP configuration
  exchange_name 'status'
  exchange_type :topic
  queue_name    'roundhousekiq_status_worker'
  routing_key   'status.*'

  # Attributes:
  #   payload: Parsed JSON payload directly from AMQP
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

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install roundhousekiq

## Usage

1. Create an initializer in _config/initializers/roundhousekiq.rb_ and specify
your AMQP host.

  ```ruby
  Roundhousekiq.configure do |config|
    # AMQP host address
    # config.host = '127.0.0.1'

    # AMQP host port
    # config.port = '5672'

    # AMQP vhost to be connected to
    # config.vhost = '/'

    # User credentials
    # config.username = 'guest'
    # config.password = 'guest'

    # Prefetch count on all queues Roundhousekiq will subscribe to
    # config.prefetch = 256
  end
  ```

2. Create your first worker. This worker does only differ from a normal Sidekiq
worker in the `Roundhousekiq::Worker` module being included and specifying which
exchange and routing key to listen on:

  ```ruby
  class Worker
    include Sidekiq::Worker
    include Roundhousekiq::Worker

    exchange_name 'amq.topic'
    exchange_type :topic
    queue_name    'worker'
    routing_key   'work'

    def perform(payload)
      # ...
    end
  end
  ```

  A persistent queue named _worker_ bound to the _amq.topic_ exchange with the
  routing key _work_ will be created. Each time a message arrives in that
  queue, this worker will be triggered.

  You do not have to specify a queue name, if you do not want to have a
  persistent queue. AMQP will automatically create a queue for that worker,
  which is being deleted once the Roundhousekiq daemon shuts down.

3. Run the Roundhousekiq daemon from the root of your Rails project:

  ```shell
  $ bundle exec roundhousekiq
  ```
