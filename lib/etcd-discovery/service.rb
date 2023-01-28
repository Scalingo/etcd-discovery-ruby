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
        return new service.node
      rescue Etcd::KeyNotFound
        return new("name" => service)
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
      return node.children.map { |c| Host.new(c) }
    end

    def one
      all.sample
    end

    def to_uri(schemes = ["https", "http"])
      a = attributes
      return one.to_uri(schemes) unless a["public"]

      schemes = [schemes] if !schemes.is_a?(Array)
      scheme = schemes.reject do |s|
        a["ports"][s].nil?
      end.first
      if a["user"].nil? || a["user"] == ""
        URI("#{scheme}://#{a["hostname"]}:#{a["ports"][scheme]}")
      else
        URI("#{scheme}://#{a["user"]}:#{a["password"]}@#{a["hostname"]}:#{a["ports"][scheme]}")
      end
    end

    def to_s
      to_uri.to_s
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
