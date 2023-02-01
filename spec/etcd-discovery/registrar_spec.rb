require "spec_helper"

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
    its(:host_key) { is_expected.to start_with "/services/service/" }
  end

  context "with a registered client" do
    let(:info) do
      {
        "name" => "service",
        "critical" => true,
        "hostname" => "public.scalingo.test",
        "user" => "user",
        "password" => "secret",
        "ports" => {"https" => "5000", "http" => 80},
        "public" => true
      }
    end
    let(:host) do
      {
        "name" => info["hostname"],
        "service_name" => info["name"],
        "ports" => info["ports"],
        "user" => info["user"],
        "password" => info["secret"],
        "public" => info["public"],
        "private_ports" => info["ports"],
        "critical" => info["critical"],
        "private_hostname" => "private01.scalingo.test",
        "uuid" => "my-uuid"
      }
    end
    subject do
      EtcdDiscovery::Registrar.new(
        info["name"],
        EtcdDiscovery::Host.new({"name" => info["hostname"], "ports" => info["ports"]})
      )
    end

    before(:each) do
      mock_service_info(info["name"], info, true)
      mock_hosts(info["name"], host, 1)
      mock_set_service_key(info["name"])
      mock_set_host_key(info["name"], subject.host.attributes["uuid"])

      subject.register
      sleep 0.2
    end

    after(:each) do
      mock_delete_host_key(info["name"], subject.host.attributes["uuid"])
      subject.stop if subject.state == :started
    end

    describe "#stop" do
      it "should stop its registering thread" do
        mock_delete_host_key(info["name"], subject.host.attributes["uuid"])

        subject.stop
        sleep 0.2
        expect(subject.thread.alive?).to eq false
      end

      it "should set the service state to stopped" do
        mock_service_info(info["name"], info)
        mock_delete_host_key(info["name"], subject.host.attributes["uuid"])
        expect(EtcdDiscovery.get(info["name"]).all.length).to eq 1

        subject.stop

        expect(subject.state).to eq :stopped
      end
    end
  end
end
