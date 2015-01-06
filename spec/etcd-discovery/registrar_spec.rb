require 'spec_helper.rb'

RSpec.describe EtcdDiscovery::Registrar do
  describe '.new' do
    context 'with a Hash' do
      subject { EtcdDiscovery::Registrar.new "service", {"name" => "example.com", "ports" => {"http" => 80}} }
      it "should transform the has in Host" do
        expect(subject.host.attributes["name"]).to eq "example.com"
      end
    end

    context 'with a EtcdDiscovery::Host' do
      subject { EtcdDiscovery::Registrar.new "service", EtcdDiscovery::Host.new({"name" => "example.com", "ports" => {"http" => 80}}) }
      it "should defines the state to new" do
        expect(subject.state).to eq :new
      end
    end
  end

  describe '#register' do
    subject { EtcdDiscovery::Registrar.new "service", EtcdDiscovery::Host.new({"name" => "example.com", "ports" => {"http" => 80}}) }
    it "should start a registering thread" do
      subject.register
      expect(subject.thread).not_to eq nil
      expect(subject.thread.alive?).to eq true
    end
  end

  describe '#stop' do
    subject { EtcdDiscovery::Registrar.new "service", EtcdDiscovery::Host.new({"name" => "example.com", "ports" => {"http" => 80}}) }
    it "should change the state to stopped" do
      subject.stop
      expect(subject.state).to eq :stopped
    end

    it "should stop its registering thread" do
      subject.register
      subject.stop
      sleep 1
      expect(subject.thread.alive?).to eq false
    end
  end
end
