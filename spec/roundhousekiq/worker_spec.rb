require './spec/fixtures/dummy_worker'

describe Roundhousekiq::Worker do

  # Method existence
  it { should respond_to :included }

  describe '.included' do
    it 'extends the class methods module' do
      worker = double('worker')
      expect(worker).to receive(:extend)
                          .with(Roundhousekiq::Worker::ClassMethods)
      Roundhousekiq::Worker.send :included, worker
    end

    it 'registers the worker' do
      worker = double('worker')
      expect(Roundhousekiq::Workers).to receive(:register).with(worker)
      Roundhousekiq::Worker.send :included, worker
    end
  end

  describe '::ClassMethods' do
    subject { DummyWorker }

    it { should respond_to :exchange_name }
    it { should respond_to :exchange_type }
    it { should respond_to :queue_name }
    it { should respond_to :routing_key }

    describe '.exchange_name' do
      it 'calls Roundhousekiq::Workers#exchange_name_for' do
        expect(Roundhousekiq::Workers).to receive(:exchange_name_for)
                                            .with(subject, 'notifications')
        subject.exchange_name 'notifications'
      end
    end

    describe '.exchange_type' do
      it 'calls Roundhousekiq::Workers#exchange_type_for' do
        expect(Roundhousekiq::Workers).to receive(:exchange_type_for)
                                            .with(subject, 'topic')
        subject.exchange_type 'topic'
      end
    end

    describe '.queue_name' do
      it 'calls Roundhousekiq::Workers#queue_name_for' do
        expect(Roundhousekiq::Workers).to receive(:queue_name_for)
                                            .with(subject, 'queue')
        subject.queue_name 'queue'
      end
    end

    describe '.routing_key' do
      it 'calls Roundhousekiq::Workers#routing_key_for' do
        expect(Roundhousekiq::Workers).to receive(:routing_key_for)
                                            .with(subject, 'key.*')
        subject.routing_key 'key.*'
      end
    end
  end

end
