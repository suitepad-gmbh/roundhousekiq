module Roundhousekiq
  class WorkerDefinition

    attr_reader :exchange, :queue

    def initialize
      @exchange = {}
      @queue = {}
    end

    def exchange_name=(name)
      exchange[:name] = name
    end

    def exchange_type=(type)
      exchange[:type] = type
    end

    def queue_name=(name)
      name ||= '' # Default name to empty string

      queue[:name]        = name
      queue[:durable]     = name != ''
      queue[:auto_delete] = name == ''
    end

    def routing_key=(key)
      queue[:routing_key] = key
    end

  end
end
