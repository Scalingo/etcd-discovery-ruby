module EtcdDiscovery
  module Client
    def self.create(config)
      if config.use_ssl
        Etcd.client host: config.host, port: config.port do |config|
          config.use_ssl = true
          config.ca_file = File.expand_path(ENV["ETCD_CACERT"], __FILE__)
          config.ssl_cert = OpenSSL::X509::Certificate.new(File.read(ENV["ETCD_TLS_CERT"]))
          config.ssl_key = OpenSSL::PKey::RSA.new(File.read(ENV["ETCD_TLS_KEY"]))
        end
      else
        Etcd.client host: config.host, port: config.port
      end
    end
  end
end
