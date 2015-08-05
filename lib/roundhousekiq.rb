require 'bunny'
require 'roundhousekiq/configuration'
require 'roundhousekiq/runner'
require 'roundhousekiq/version'
require 'roundhousekiq/worker'
require 'roundhousekiq/workers'
require 'roundhousekiq/worker_definition'

module Roundhousekiq
  def self.configure
    @config = Configuration.new
    yield(@config) if block_given?
    @config
  end

  def self.config
    @config || configure
  end
end
