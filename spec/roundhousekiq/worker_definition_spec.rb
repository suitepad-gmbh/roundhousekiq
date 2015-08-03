describe Roundhousekiq::WorkerDefinition do
  let(:definition) { Roundhousekiq::WorkerDefinition.new }

  # Method existence
  it { should respond_to :exchange }
  it { should respond_to :queue }
  it { should respond_to :exchange_name= }
  it { should respond_to :exchange_type= }
  it { should respond_to :queue_name= }
  it { should respond_to :routing_key= }

  describe '#exchange' do
    it 'returns a hash' do
      expect(definition.exchange).to be_instance_of Hash
    end
  end

  describe '#exchange_name' do
    it 'sets the name key in exchange' do
      expect(definition.exchange[:name]).to be_nil
      definition.exchange_name = 'rspec'
      expect(definition.exchange[:name]).to match('rspec')
    end
  end

  describe '#exchange_type' do
    it 'sets the type key in exchange' do
      expect(definition.exchange[:type]).to be_nil
      definition.exchange_type = 'topic'
      expect(definition.exchange[:type]).to match('topic')
    end
  end

  describe '#queue_name' do
    it 'sets the name in queue hash' do
      expect(definition.queue[:name]).to be_nil
      definition.queue_name = 'queue'
      expect(definition.queue[:name]).to match('queue')
    end

    it 'defaults the queue name to empty string' do
      expect(definition.queue[:name]).to be_nil
      definition.queue_name = nil
      expect(definition.queue[:name]).to match('')
    end

    it 'defines queue as durable for a named queue' do
      definition.queue_name = 'named_queue'
      expect(definition.queue[:durable]).to be true
    end

    it 'defines queue as non-durable for auto-generated queues' do
      definition.queue_name = nil
      expect(definition.queue[:durable]).to be false
    end

    it 'does not mark queue for auto-delete for a named queue' do
      definition.queue_name = 'named_queue'
      expect(definition.queue[:auto_delete]).to be false
    end

    it 'marks queue for auto-delete for auto-generated queues' do
      definition.queue_name = nil
      expect(definition.queue[:auto_delete]).to be true
    end
  end

  describe '#routing_key' do
    it 'sets the routing key in queue' do
      expect(definition.queue[:routing_key]).to be_nil
      definition.routing_key = 'routeMe'
      expect(definition.queue[:routing_key]).to match('routeMe')
    end
  end

end
