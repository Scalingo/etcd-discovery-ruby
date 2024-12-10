module EtcdDiscovery
  class ServiceNotFound < RuntimeError
  end

  class Service
    attr_accessor :attributes

    def initialize(arg)
      if arg.is_a? Etcd::Node
        @attributes = JSON.parse arg.value
      elsif arg.is_a? Hash
        @attributes = arg
      else
        raise TypeError, "requires a Etcd::Node or a Hash, not a #{arg.class}"
      end
    end

    def self.get(service)
      raise TypeError, "service should be a String, is a #{service.class}" unless service.is_a? String

      client = EtcdDiscovery.config.client
      begin
        service = client.get("/services_infos/#{service}")
        new service.node
      rescue Etcd::KeyNotFound
        new("name" => service)
      end
    end

    def all
      client = EtcdDiscovery.config.client
      begin
        node = client.get("/services/#{attributes["name"]}", recursive: true).node
      rescue Etcd::KeyNotFound
        raise ServiceNotFound, attributes["name"]
      end
      raise ServiceNotFound, attributes["name"] if node.children.empty?
      node.children.map { |c| Host.new(c) }
    end

    def one
      all.sample
    end

    def to_uri(schemes = ["https", "http"])
      schemes = Array(schemes)

      a = attributes
      return one.to_uri(schemes) unless a["public"]

      scheme = schemes.find { |s| a["ports"][s] }
      raise "No valid scheme found" unless scheme

      if a["user"].nil? || a["user"].empty?
        return URI("#{scheme}://#{a["hostname"]}:#{a["ports"][scheme]}")
      end

      URI("#{scheme}://#{a["user"]}:#{a["password"]}@#{a["hostname"]}:#{a["ports"][scheme]}")
    end

    def to_s
      uri = to_uri
      if uri.userinfo
        user, _password = uri.userinfo.split(":", 2)
        uri.userinfo = "#{user}:REDACTED"
      end
      uri.to_s
    end

    def to_json
      attributes.to_json
    end

    def set_credentials(user, password)
      @attributes["user"] = user
      @attributes["password"] = password
    end
  end
end
