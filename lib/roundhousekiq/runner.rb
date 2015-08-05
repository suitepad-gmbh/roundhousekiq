module Roundhousekiq
  class Runner

    attr_accessor :connection, :channel, :queue, :consumer, :shutdown_runner,
                  :exchange, :error_exchange, :queues, :queue_worker_map

    ##################################
    # Public API
    ##################################

    def initialize
      self.queues = []
      self.queue_worker_map = {}
    end

    def run
      establish_connection
      create_channel
      create_exchanges_and_queues
      setup_subscribers
    end

    def shutdown
      # Give runner time to finish its work
      self.shutdown_runner = true
      sleep 10

      # Spawn new thread for closing the connection. Connection cannot be closed
      # from current thread (being in TRAP context).
      Thread.new { self.connection.try :close }

      # Sleep again to wait for connection close
      sleep 10
    end

    def shutdown?
      self.shutdown_runner
    end


    ##################################
    # Connection
    ##################################

    def establish_connection
      options = { properties: self.class.client_settings }

      self.connection = Bunny.new self.class.connection_settings, options
      self.connection.start
    end

    def self.connection_settings
      config = Roundhousekiq.config.to_h
      config.select { |k, v| %i(host port vhost username password).include? k }
    end

    def self.client_settings
      Bunny::Session::DEFAULT_CLIENT_PROPERTIES.merge product: 'Roundhousekiq'
    end

    def create_channel
      self.channel = self.connection.create_channel
      self.channel.prefetch Roundhousekiq.config.prefetch
      self.channel
    end

    def create_exchanges_and_queues
      Workers.definitions.each do |worker, definition|
        exchange = self.channel.exchange(
          definition.exchange[:name],
          type: definition.exchange[:type],
          durable: true
        )

        queue = self.channel.queue(
          definition.queue[:name],
          auto_delete: definition.queue[:auto_delete],
          durable: definition.queue[:durable]
        ).bind(exchange, routing_key: definition.queue[:routing_key])

        self.queues << queue
        self.queue_worker_map[queue] = worker
      end
    end

    def setup_subscribers
      self.queues.each do |queue|
        queue.subscribe(manual_ack: true) do |delivery_info, metadata, payload|
          self.channel.ack delivery_info.delivery_tag
          process_message queue, payload
        end
      end

      while not self.shutdown?
        sleep 5
      end
    end

    def process_message(queue, payload)
      queue_worker_map[queue].perform_async JSON.parse(payload)
    end
  end
end
