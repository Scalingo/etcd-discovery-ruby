module EtcdDiscovery
  class Registration
    def self.register(service, host)
      EtcdDiscovery::Registrar.new(service, host).register
    end
  end
end
