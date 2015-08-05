module Roundhousekiq
  module Worker
    def self.included(base)
      Workers.register base
      base.extend ClassMethods
    end

    module ClassMethods
      def exchange_name(name)
        Workers.exchange_name_for self, name
      end

      def exchange_type(type)
        Workers.exchange_type_for self, type
      end

      def queue_name(name)
        Workers.queue_name_for self, name
      end

      def routing_key(key)
        Workers.routing_key_for self, key
      end
    end
  end
end
