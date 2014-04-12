module EtcdDiscovery
  module Client
    def self.create(config)
      if config.use_ssl
        Etcd.client host: config.host, port: config.port do |c|
          c.use_ssl = true
          c.ca_file = File.expand_path(config.cacert, __FILE__)
          c.ssl_cert = OpenSSL::X509::Certificate.new(File.read(config.ssl_cert))
          c.ssl_key = OpenSSL::PKey::RSA.new(File.read(config.ssl_key))
        end
      else
        Etcd.client host: config.host, port: config.port
      end
    end
  end
end
