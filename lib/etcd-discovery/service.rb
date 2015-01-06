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
      EtcdDiscovery::Registrar.new(service, host).register
    end
  end
end
