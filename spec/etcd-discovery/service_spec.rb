require "spec_helper"

## Info
# {
#   "name":"service01",
#   "critical":true,
#   "hostname":"public.scalingo.test",
#   "user":"user",
#   "password":"secret",
#   "ports":{"https":"5000"},
#   "public":true
# }
#
## Host
# {
#   "name":"public.scalingo.test",
#   "service_name":"service01",
#   "ports":{"https":"5000"},
#   "user":"user",
#   "password":"secret",
#   "public":true,
#   "private_hostname":"private01.scalingo.test",
#   "private_ports":{"https":"5000"},
#   "critical":false,
#   "uuid":"4186d8d5-36de-4781-73f2-c72a42f3f7b2-private01.scalingo.test"
# }

RSpec.describe EtcdDiscovery::Service do
  subject { EtcdDiscovery::Service }

  let(:info) do
    {
      "name" => "service01",
      "critical" => true,
      "hostname" => "public.scalingo.test",
      "user" => "user",
      "password" => "secret",
      "ports" => {"https" => "5000"},
      "public" => true
    }
  end
  let(:host) do
    {
      "name" => "public.scalingo.test",
      "service_name" => "service01",
      "ports" => {"https" => "5000"},
      "user" => "user",
      "password" => "secret",
      "public" => true,
      "private_hostname" => "private01.scalingo.test",
      "private_ports" => {"https" => "5000"},
      "critical" => false,
      "uuid" => "4186d8d5-36de-4781-73f2-c72a42f3f7b2-private01.scalingo.test"
    }
  end

  describe "::new" do
    it "should create a new service without making any request" do
      service = subject.new("name" => "service01")
      expect(service.attributes["name"]).to eq "service01"
    end

    it "should accept an Etcd::Node to create a service from" do
      service = subject.new(Etcd::Node.new("value" => info.to_json))
      expect(service.attributes["name"]).to eq "service01"
    end
  end

  describe "::get" do
    it "should return a service from the right type" do
      mock_not_found("service01")
      service = subject.get("service01")
      expect(service.attributes["name"]).to eq "service01"
      expect(service.attributes["public"]).to eq nil
    end

    it "should return an populated service from the services_infos registry" do
      mock_service_info("service01", info)
      service = subject.get("service01")
      expect(service.attributes["name"]).to eq "service01"
      expect(service.attributes["public"]).to eq true
    end
  end

  describe "#all" do
    it "should return all the registered nodes for the given service" do
      mock_not_found("service01")
      mock_hosts("service01", host, 2)
      service = subject.get("service01")
      hosts = service.all
      expect(hosts.length).to eq 2
      expect(hosts[0].attributes["name"]).to eq "service01-0.scalingo.test"
      expect(hosts[1].attributes["name"]).to eq "service01-1.scalingo.test"
    end
  end

  describe "#one" do
    it "should return one of the hosts" do
      mock_not_found("service01")
      mock_hosts("service01", host, 2)
      service = subject.get("service01")
      host = service.one
      expected = ["service01-0.scalingo.test", "service01-1.scalingo.test"]
      expect(expected).to include host.attributes["name"]
    end
  end

  describe "#to_uri" do
    it "should get the URI of one of the hosts if private" do
      mock_not_found("service01")
      mock_hosts("service01", host, 1)
      service = subject.get("service01")
      expect(service.to_uri.to_s).to eq "https://user:secret@service01-0.scalingo.test:5000"
    end

    it "should get the URI of the service if public" do
      mock_service_info("service01", info)
      service = subject.get("service01")
      expect(service.to_uri.to_s).to eq "https://user:secret@public.scalingo.test:5000"
    end
  end

  # To get the private URI of a public service
  describe "#one.to_uri" do
    it "should get the URI of the private host even if service is public" do
      mock_service_info("service01", info)
      mock_hosts("service01", host, 1)
      service = subject.get("service01")
      expect(service.one.to_uri.to_s).to eq "https://user:secret@service01-0.scalingo.test:5000"
    end
  end
end
