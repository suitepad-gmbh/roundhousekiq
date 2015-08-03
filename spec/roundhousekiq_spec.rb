describe Roundhousekiq do

  # Method existence
  it { should respond_to :config }
  it { should respond_to :configure }

  describe '.config' do
    it 'returns a Configuration' do
      expect(Roundhousekiq.config).to be_instance_of Roundhousekiq::Configuration
    end

    it 'always returns the same configuration' do
      config = Roundhousekiq.config
      expect(Roundhousekiq.config).to eq config
    end
  end

  describe '.configure' do
    it 'passes the Gem configuration to a block' do
      Roundhousekiq.configure do |config|
        expect(config).to be_instance_of Roundhousekiq::Configuration
      end
    end

    it 'stores the configuration' do
      configuration = nil
      Roundhousekiq.configure do |config|
        configuration = config
      end

      expect(Roundhousekiq.instance_variable_get '@config').to eq configuration
    end
  end
end
