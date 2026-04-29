require "spec_helper"

RSpec.describe EtcdDiscovery do
  describe ".get" do
    it "accepts shard as a named argument" do
      mock_service_not_found("service01")
      service = described_class.get("service01", shard: "shard-0")
      expect(service.shard).to eq "shard-0"
    end
  end
end
