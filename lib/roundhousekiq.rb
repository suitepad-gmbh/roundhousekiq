require "roundhousekiq/configuration"
require "roundhousekiq/version"

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
