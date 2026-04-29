module EtcdHelper
  def mock_service_not_found(service)
    WebMock.stub_request(:get, "http://localhost:2379/v2/keys/services_infos/#{service}")
      .to_return(
        status: 404,
        body: {"cause" => "", "index" => "", "errorCode" => 100}.to_json
      )
  end

  def mock_service_info(service, info, recursive = false)
    uri = "http://localhost:2379/v2/keys/services_infos/#{service}"
    uri = "#{uri}?recursive=true" if recursive
    WebMock.stub_request(:get, uri)
      .to_return(
        status: 200,
        body: {
          "action" => "get", "node" => {
            "createIndex" => 1, "modifiedIndex" => 1, "dir" => false, "value" => info.to_json
          }
        }.to_json
      )
  end

  def mock_hosts(service, value, count = nil)
    hosts = if value.is_a?(Array)
      value
    else
      raise ArgumentError, "count is required when value is not an Array" if count.nil?

      Array.new(count) do |i|
        host = JSON.parse(value.to_json)
        host["name"] = "#{service}-#{i}.scalingo.test"
        host
      end
    end

    WebMock.stub_request(:get, "http://localhost:2379/v2/keys/services/#{service}?recursive=true").to_return do
      {
        body: {
          action: "get",
          node: {
            createdIndex: 1, modifiedIndex: 1, dir: true, key: "/services/#{service}",
            nodes: hosts.map do |host|
              {
                createdIndex: 2, modifiedIndex: 2, dir: false,
                value: host.to_json
              }
            end
          }
        }.to_json
      }
    end
  end

  def mock_delete_host_key(service, host_uuid)
    WebMock.stub_request(
      :delete, "http://localhost:2379/v2/keys/services/#{service}/#{host_uuid}"
    ).to_return(
      status: 200,
      body: {
        "action" => "get", "node" => {
          "createIndex" => 1, "modifiedIndex" => 1, "dir" => false, "value" => {}.to_json
        }
      }.to_json
    )
  end

  def mock_set_service_key(service)
    WebMock.stub_request(:put, "http://localhost:2379/v2/keys/services_infos/#{service}")
      .to_return(
        status: 200,
        body: {
          "action" => "get", "node" => {
            "createIndex" => 1, "modifiedIndex" => 1, "dir" => false, "value" => {}.to_json
          }
        }.to_json
      )
  end

  def mock_set_host_key(service, host_uuid)
    WebMock.stub_request(
      :put, "http://localhost:2379/v2/keys/services/#{service}/#{host_uuid}"
    ).to_return(
      status: 200,
      body: {
        "action" => "get", "node" => {
          "createIndex" => 1, "modifiedIndex" => 1, "dir" => false, "value" => {}.to_json
        }
      }.to_json
    )
  end
end
