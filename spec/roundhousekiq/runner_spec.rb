require 'bunny'
require './spec/fixtures/dummy_worker'

describe Roundhousekiq::Runner do

  # Method existence
  it { should respond_to :connection }
  it { should respond_to :channel }
  it { should respond_to :queue }
  it { should respond_to :consumer }
  it { should respond_to :shutdown_runner }
  it { should respond_to :exchange }
  it { should respond_to :error_exchange }
  it { should respond_to :queues }
  it { should respond_to :queue_worker_map }
  it { should respond_to :run }

  describe 'constructor' do
    it 'initializes queues with empty array' do
      expect(subject.queues).to eq []
    end

    it 'initializes queue_worker_map with empty hash' do
      expect(subject.queue_worker_map).to eq({})
    end
  end

  describe '#run' do
    before :each do
      allow(subject).to receive(:establish_connection).and_return(nil)
      allow(subject).to receive(:create_channel).and_return(nil)
      allow(subject).to receive(:create_exchanges_and_queues).and_return(nil)
      allow(subject).to receive(:setup_subscribers).and_return(nil)
    end

    it 'establishes an AMQP connection' do
      expect(subject).to receive(:establish_connection)
      subject.run
    end

    it 'creates a channel' do
      expect(subject).to receive(:create_channel)
      subject.run
    end

    it 'creates exchanges and queues' do
      expect(subject).to receive(:create_exchanges_and_queues)
      subject.run
    end

    it 'sets up subscribers' do
      expect(subject).to receive(:setup_subscribers)
      subject.run
    end
  end

  describe '#shutdown' do
    before :each do
      allow(subject).to receive(:sleep).and_return(nil)
    end

    it 'sets shutdown_runner to true' do
      allow(Thread).to receive(:new).and_return(nil)
      expect(subject.shutdown_runner).to be_falsy
      subject.shutdown
      expect(subject.shutdown_runner).to be true
    end

    it 'closes the connection' do
      subject.connection = double('connection')

      allow(Thread).to receive(:new) do |&block|
        expect(subject.connection).to receive(:try).with(:close)
        block.call
      end

      subject.shutdown
    end
  end

  describe '#shutdown?' do
    it 'returns true if shutdown_runner is true' do
      subject.shutdown_runner = true
      expect(subject.shutdown?).to be true
    end

    it 'returns false if shutdown_runner is false' do
      subject.shutdown_runner = false
      expect(subject.shutdown?).to be false
    end
  end

  describe '#establish_connection' do
    before :each do
      allow(Bunny).to receive(:new).and_return double('bunny', start: nil)
    end

    it 'creates a new Bunny instance' do
      expect(Bunny).to receive(:new)
      subject.establish_connection
    end

    it 'passes connection settings on to Bunny' do
      settings = subject.class.connection_settings
      expect(Bunny).to receive(:new).with(settings, any_args)
      subject.establish_connection
    end

    it 'passes client properties on to Bunny' do
      settings = subject.class.client_settings
      expect(Bunny).to receive(:new).with(any_args, properties: settings)
      subject.establish_connection
    end

    it 'calls #start on the connection' do
      bunny = double('bunny', start: nil)
      allow(Bunny).to receive(:new).and_return bunny
      expect(bunny).to receive(:start)
      subject.establish_connection
    end
  end

  describe '.connection_settings' do
    subject { Roundhousekiq::Runner }

    it 'it requests the settings from Roundhousekiq' do
      expect(Roundhousekiq).to receive(:config)
      subject.connection_settings
    end

    it 'it returns a hash' do
      expect(subject.connection_settings).to be_instance_of Hash
    end

    it 'it returns a hash with host, port, vhost, username and password' do
      settings = subject.connection_settings

      expect(settings).to have_key :host
      expect(settings).to have_key :port
      expect(settings).to have_key :vhost
      expect(settings).to have_key :username
      expect(settings).to have_key :password
    end

    it 'returns the settings configured in Roundhousekiq' do
      Roundhousekiq.configure do |config|
        config.host     = 'amqp-host'
        config.port     = 1234
        config.vhost    = 'rspec'
        config.username = 'rspec_user'
        config.password = 'very_secure'
      end

      settings = subject.connection_settings
      expect(settings[:host]).to match 'amqp-host'
      expect(settings[:port]).to match 1234
      expect(settings[:vhost]).to match 'rspec'
      expect(settings[:username]).to match 'rspec_user'
      expect(settings[:password]).to match 'very_secure'
    end
  end

  describe '.client_settings' do
    subject { Roundhousekiq::Runner }

    it 'takes the Bunny default settings' do
      expect(Bunny::Session::DEFAULT_CLIENT_PROPERTIES).to receive(:merge)
      subject.client_settings
    end

    it 'returns a hash' do
      expect(subject.client_settings).to be_instance_of Hash
    end

    it 'sets the product name to "Roundhousekiq"' do
      settings = subject.client_settings
      expect(settings[:product]).to match 'Roundhousekiq'
    end
  end

  describe '#create_channel' do
    it 'sets up a new channel' do
      channel = double('channel', prefetch: nil)
      subject.connection = double('connection', create_channel: channel)
      subject.create_channel
    end

    it 'sets the prefetch count to the value configured in config' do
      config = double('config', prefetch: 512)
      channel = double('channel', prefetch: nil)
      subject.connection = double('connection', create_channel: channel)
      expect(Roundhousekiq).to receive(:config).and_return config
      expect(config).to receive(:prefetch)
      expect(channel).to receive(:prefetch).with 512
      subject.create_channel
    end
  end

  describe '#create_exchanges_and_queues' do
    let(:exchange) { double('exchange') }
    let(:queue) { double('queue', bind: nil) }
    let(:channel) { double('channel', exchange: exchange, queue: queue) }
    let(:definition) do
      definition = double 'definition'
      allow(definition).to receive(:exchange).and_return({
        name: 'exchange_name',
        type: 'topic'
      })
      allow(definition).to receive(:queue).and_return({
        name: 'queue_name',
        durable: true,
        auto_delete: false,
        routing_key: 'routing_key'
      })
      definition
    end

    before :each do
      subject.channel = channel
      allow(Roundhousekiq::Workers).to receive(:definitions).and_return(
        { DummyWorker => definition }
      )
    end

    it 'requests the worker definitions from Roundhousekiq::Workers' do
      subject.create_exchanges_and_queues
    end

    it 'creates the exchange for each worker' do
      expect(channel).to receive(:exchange).with(
        'exchange_name', type: 'topic', durable: true
      )
      subject.create_exchanges_and_queues
    end

    it 'creates a queue for each worker' do
      expect(channel).to receive(:queue).with(
        'queue_name', auto_delete: false, durable: true
      )
      subject.create_exchanges_and_queues
    end

    it 'sets up the binding for each worker' do
      allow(channel).to receive(:queue).and_return queue
      expect(queue).to receive(:bind).with exchange, routing_key: 'routing_key'
      subject.create_exchanges_and_queues
    end

    it 'saves the queue in queues' do
      allow(queue).to receive(:bind).and_return queue
      subject.create_exchanges_and_queues
      expect(subject.queues.include? queue).to be true
    end

    it 'adds each worker with the queue as key to the worker map' do
      allow(queue).to receive(:bind).and_return queue
      subject.create_exchanges_and_queues
      expect(subject.queue_worker_map.keys.include? queue).to be true
      expect(subject.queue_worker_map[queue]).to eq DummyWorker
    end
  end

  describe '#setup_subscribers' do
    let(:queue) { double('queue', subscribe: nil) }
    let(:channel) { double('channel', ack: nil) }

    before :each do
      allow(subject).to receive(:sleep).and_return(nil)
      allow(subject).to receive(:shutdown?).and_return(true)
      allow(subject).to receive(:process_message).and_return(nil)
      allow(subject).to receive(:queues).and_return([queue])
      allow(subject).to receive(:channel).and_return(channel)
    end

    it 'sets up a subscription for each queue' do
      expect(queue).to receive(:subscribe)
      subject.setup_subscribers
    end

    it 'configures manual ACK for the subscriptions' do
      expect(queue).to receive(:subscribe).with(manual_ack: true)
      subject.setup_subscribers
    end

    it 'ACK each message once received' do
      allow(queue).to receive(:subscribe) do |&block|
        expect(subject.channel).to receive(:ack).with('amqp_tag')

        block.call(
          double('info', delivery_tag: 'amqp_tag'),
          {},
          "\{\}"
        )
      end
      subject.setup_subscribers
    end

    it 'passes the received message to #process_message' do
      allow(channel).to receive(:ack).and_return(nil)

      payload = JSON.dump('foo' => 'bar')

      allow(queue).to receive(:subscribe) do |&block|
        expect(subject).to receive(:process_message)
                            .with(queue, payload)

        block.call(
          double('info', delivery_tag: 'amqp_tag'),
          {},
          payload
        )
      end
      subject.setup_subscribers
    end

    it 'blocks in a loop until shutdown and just sleeps in between' do
      allow(subject).to receive(:shutdown?).and_return(false, true)

      expect(subject).to receive(:shutdown?).twice
      expect(subject).to receive(:sleep).once
      subject.setup_subscribers
    end
  end

  describe '#process_message' do
    let(:worker) { double('worker', perform_async: nil) }

    it 'fetches the corresponding worker' do
      expect(subject.queue_worker_map).to receive(:[]).with('queue')
                                                      .and_return(worker)
      subject.process_message 'queue', "\{\}"
    end

    it 'schedules the worker' do
      allow(subject.queue_worker_map).to receive(:[]).with('queue')
                                                     .and_return(worker)
      expect(worker).to receive(:perform_async)
      subject.process_message 'queue', "\{\}"
    end

    it 'parses the message payload and passes it to the worker' do
      allow(subject.queue_worker_map).to receive(:[]).with('queue')
                                                     .and_return(worker)

      payload = { 'foo' => 'bar' }
      expect(worker).to receive(:perform_async).with payload
      subject.process_message 'queue', JSON.dump(payload)
    end
  end
end
