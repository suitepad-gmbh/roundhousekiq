module Roundhousekiq
  class Configuration < Struct.new(:host, :port, :vhost, :username, :password, :prefetch)
    def initialize
      # AMQP connection
      self.host     = '127.0.0.1'
      self.port     = '5672'
      self.vhost    = '/'
      self.prefetch = 256

      # AMQP auth
      self.username = 'guest'
      self.password = 'guest'
    end
  end
end
