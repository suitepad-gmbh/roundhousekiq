module Roundhousekiq
  class Workers
    class << self
      def register(worker)
        if definitions.key? worker
          warn "Worker class #{worker.to_s} already registered"
        end

        definitions[worker] = WorkerDefinition.new
      end

      def definitions
        @@definitions ||= {}
      end

      def exchange_name_for(worker, name)
        definition = definitions[worker]
        fail "Unknown worker class passed: #{worker}" unless definition
        definition.exchange_name = name
      end

      def exchange_type_for(worker, type)
        definition = definitions[worker]
        fail "Unknown worker class passed: #{worker}" unless definition
        definition.exchange_type = type
      end

      def queue_name_for(worker, name)
        definition = definitions[worker]
        fail "Unknown worker class passed: #{worker}" unless definition
        definition.queue_name = name
      end

      def routing_key_for(worker, key)
        definition = definitions[worker]
        fail "Unknown worker class passed: #{worker}" unless definition
        definition.routing_key = key
      end
    end

  end
end
