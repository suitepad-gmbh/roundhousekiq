require './spec/fixtures/dummy_worker'

describe Roundhousekiq::Workers do
  subject { Roundhousekiq::Workers }

  # Methods
  it { should respond_to :register }
  it { should respond_to :definitions }
  it { should respond_to :exchange_name_for }
  it { should respond_to :exchange_type_for }
  it { should respond_to :queue_name_for }
  it { should respond_to :routing_key_for }

  describe '.register' do
    it 'creates a new definition for the given class' do
      Roundhousekiq::Workers.register DummyWorker
      definitions = Roundhousekiq::Workers.definitions
      expect(definitions).to have_key DummyWorker
      expect(definitions[DummyWorker]).to be_instance_of(
        Roundhousekiq::WorkerDefinition
      )
    end
  end

  describe '.definitions' do
    it 'returns the internal definitions hash' do
      definitions = Roundhousekiq::Workers.class_variable_get '@@definitions'
      expect(Roundhousekiq::Workers.definitions).to eq definitions
    end
  end

  describe '.exchange_name_for' do
    it 'passes the exchange name to the workers definition' do
      worker = double('worker')
      Roundhousekiq::Workers.register worker
      definition = Roundhousekiq::Workers.definitions[worker]
      expect(definition).to receive(:exchange_name=).with 'notifications'
      subject.exchange_name_for worker, 'notifications'
    end
  end

  describe '.exchange_type_for' do
    it 'passes the exchange type to the workers definition' do
      worker = double('worker')
      Roundhousekiq::Workers.register worker
      definition = Roundhousekiq::Workers.definitions[worker]
      expect(definition).to receive(:exchange_type=).with 'topic'
      subject.exchange_type_for worker, 'topic'
    end
  end

  describe '.queue_name_for' do
    it 'passes the queue name to the workers definition' do
      worker = double('worker')
      Roundhousekiq::Workers.register worker
      definition = Roundhousekiq::Workers.definitions[worker]
      expect(definition).to receive(:queue_name=).with 'importantQueue'
      subject.queue_name_for worker, 'importantQueue'
    end
  end

  describe '.routing_key_for' do
    it 'passes the routing key to the workers definition' do
      worker = double('worker')
      Roundhousekiq::Workers.register worker
      definition = Roundhousekiq::Workers.definitions[worker]
      expect(definition).to receive(:routing_key=).with 'notifications.*'
      subject.routing_key_for worker, 'notifications.*'
    end
  end
end
