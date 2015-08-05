require 'sidekiq'

class DummyWorker
  include Sidekiq::Worker
  include Roundhousekiq::Worker
end
