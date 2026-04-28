module EtcdDiscovery
  class ServiceNotFound < RuntimeError
  end

  class Service
    attr_accessor :attributes, :shard

    def initialize(arg, shard = nil)
      if arg.is_a? Etcd::Node
        @attributes = JSON.parse arg.value
      elsif arg.is_a? Hash
        @attributes = arg
      else
        raise TypeError, "requires a Etcd::Node or a Hash, not a #{arg.class}"
      end
      @shard = shard
    end

    def self.get(service, shard: nil)
      raise TypeError, "service should be a String, is a #{service.class}" unless service.is_a? String

      client = EtcdDiscovery.config.client
      begin
        service = client.get("/services_infos/#{service}")
        new(service.node, shard)
      rescue Etcd::KeyNotFound
        new({"name" => service}, shard)
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

      hosts = node.children.map { |c| Host.new(c) }
      return hosts if @shard.nil?

      hosts = hosts.select { |host| host.attributes["shard"].to_s == @shard.to_s }
      raise ServiceNotFound, attributes["name"] if hosts.empty?

      hosts
    end

    def one
      all.sample
    end

    def to_uri(schemes = ["https", "http"], **kwargs)
      unless kwargs.empty?
        raise TypeError, "to_uri does not accept keyword arguments; pass schemes as a String or an Array"
      end

      raise TypeError, "schemes should be a String or an Array" if schemes.is_a? Hash

      schemes = Array(schemes)

      return one.to_uri(schemes) if @shard || !attributes["public"]

      scheme = schemes.find { |s| attributes["ports"][s] }
      raise "No valid scheme found" unless scheme

      if attributes["user"].nil? || attributes["user"].empty?
        return URI("#{scheme}://#{attributes["hostname"]}:#{attributes["ports"][scheme]}")
      end

      URI("#{scheme}://#{attributes["user"]}:#{attributes["password"]}@#{attributes["hostname"]}:#{attributes["ports"][scheme]}")
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
