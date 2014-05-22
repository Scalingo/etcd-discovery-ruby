module EtcdDiscovery
  class ServiceNotFound < RuntimeError
  end

  class Service
    def self.get(service)
      raise TypeError, "service should be a String, is a #{service.class}" unless service.is_a? String

      client = EtcdDiscovery.config.client
      begin
        node = client.get("/services/#{service}", recursive: true)
      rescue Etcd::KeyNotFound
        raise ServiceNotFound, service
      end
      if node.children.length == 0
        raise ServiceNotFound, service
      end

      hosts = []
      node.children.each do |c|
        hosts << Host.new(c)
      end
      return hosts
    end

    def self.register(service, host)
      if host.is_a? Hash
        h = Host.new host
      elsif host.is_a? Etcd::Host
        h = host
      else
        raise TypeError, "host should be a Hash or a Etcd::Host, is a #{host.class}"
      end

      config = EtcdDiscovery.config
      client = config.client
      value = h.to_json
      key_name = "/services/#{service}/#{h.attributes['name']}"

      while true
        begin
          client.set(key_name, value: value, ttl: config.register_ttl)
        rescue => e
          puts "Fail to set #{key_name}: #{e}, #{e.message}, #{e.class}"
        end
        sleep config.register_renew
      end
    end
  end
end
