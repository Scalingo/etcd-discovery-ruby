require "spec_helper.rb"

RSpec.describe EtcdDiscovery::Registrar do
  context "without a running client" do
    describe ".new" do
      context "with a Hash" do
        subject { EtcdDiscovery::Registrar.new "service", {"name" => "example.com", "ports" => {"http" => 80}} }
        it "should transform the has in Host" do
          expect(subject.host.attributes["name"]).to eq "example.com"
        end
      end

      context "with a EtcdDiscovery::Host" do
        subject { EtcdDiscovery::Registrar.new "service", EtcdDiscovery::Host.new({"name" => "example.com", "ports" => {"http" => 80}}) }
        it "should defines the state to new" do
          expect(subject.state).to eq :new
        end
      end
    end
  end

  context "with an unregistered client" do
    subject { EtcdDiscovery::Registrar.new "service", EtcdDiscovery::Host.new({"name" => "example.com", "ports" => {"http" => 80}}) }

    describe "#stop" do
      it "should raise an exception if service not registered" do
        expect { subject.stop }.to raise_exception EtcdDiscovery::InvalidStateError
      end
    end

    its(:client) { is_expected.to eq EtcdDiscovery.config.client }
    its(:key) { is_expected.to eq "/services/service/example.com" }
  end

  context "with a registered client" do
    subject { EtcdDiscovery::Registrar.new("service", EtcdDiscovery::Host.new({"name" => "example.com", "ports" => {"http" => 80}})) }

    before(:each) do subject.register; sleep 0.2; end
    after(:each) do subject.stop if subject.state == :started; end

    describe "#register" do
      its(:thread) { is_expected.not_to eq nil }
      it "s thread should be alived" do
        expect(subject.thread.alive?).to eq true
      end
    end

    describe "#stop" do
      it "should stop its registering thread" do
        subject.stop
        sleep 0.2
        expect(subject.thread.alive?).to eq false
      end

      it "should remote the etcd key of the service" do
        expect(EtcdDiscovery.get("service").length).to eq 1
        subject.stop
        expect { EtcdDiscovery.get("service") }.to raise_exception EtcdDiscovery::ServiceNotFound
      end
    end
  end
end
