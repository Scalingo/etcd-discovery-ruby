module EtcdHelper
  def mock_not_found(service)
    WebMock.stub_request(:get, "http://localhost:2379/v2/keys/services_infos/#{service}")
      .to_return(
        status: 404,
        body: {"cause" => "", "index" => "", "errorCode" => 100}.to_json
      )
  end

  def mock_service_info(service, info)
    WebMock.stub_request(:get, "http://localhost:2379/v2/keys/services_infos/#{service}")
      .to_return(
        status: 200,
        body: {
          "action" => "get", "node" => {
            "createIndex" => 1, "modifiedIndex" => 1, "dir" => false, "value" => info.to_json
          }
        }.to_json
      )
  end

  def mock_hosts(service, value, count)
    WebMock.stub_request(:get, "http://localhost:2379/v2/keys/services/#{service}?recursive=true").to_return do
      {
        body: {
          action: "get",
          node: {
            createdIndex: 1, modifiedIndex: 1, dir: true, key: "/services/#{service}",
            nodes: count.times.map do |i|
              value["name"] = "#{service}-#{i}.scalingo.test"
              {
                createdIndex: 2, modifiedIndex: 2, dir: false,
                value: value.to_json
              }
            end
          }
        }.to_json
      }
    end
  end
end
