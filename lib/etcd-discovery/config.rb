module EtcdDiscovery
  class InvalidSSLConfig < RuntimeError
  end

  class Config
    attr_accessor :use_ssl, :cacert, :ssl_key, :ssl_cert
    attr_accessor :register_ttl, :register_renew
    attr_accessor :host, :port

    def initialize
      @use_ssl = false
      @host = "localhost"
      @port = "2379"
      @register_ttl = 10
      @register_renew = 8
    end

    def validate
      if use_ssl
        if cacert.nil? or !File.exists? cacert
          raise InvalidSSLConfig, "cacert"
        elsif ssl_key.nil? or !File.exists? ssl_key
          raise InvalidSSLConfig, "ssl_key"
        elsif ssl_cert.nil? or !File.exists? ssl_cert
          raise InvalidSSLConfig, "ssl_cert"
        end
      end
    end

    def client
      @client ||= Client.create self
    end
  end
end
