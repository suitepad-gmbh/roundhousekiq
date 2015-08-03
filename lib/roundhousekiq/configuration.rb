module Roundhousekiq
  class Configuration < Struct.new(:host, :port, :vhost, :username, :password)
    def initialize
      # AMQP connection
      self.host   = '127.0.0.1'
      self.port   = '6379'
      self.vhost  = '/'

      # AMQP auth
      self.username = 'guest'
      self.password = 'guest'
    end
  end
end
