describe Roundhousekiq::Configuration do

  # Method existence
  it { should respond_to :host }
  it { should respond_to :host= }
  it { should respond_to :port }
  it { should respond_to :port= }
  it { should respond_to :vhost }
  it { should respond_to :vhost= }
  it { should respond_to :username }
  it { should respond_to :username= }
  it { should respond_to :password }
  it { should respond_to :password= }
  it { should respond_to :prefetch }
  it { should respond_to :prefetch= }

end
