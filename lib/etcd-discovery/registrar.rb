module EtcdDiscovery
  class Registrar
    attr_reader :state
    attr_reader :thread
    attr_reader :host

    def initialize(service, host)
      @logger = Logger.new($stdout)

      if host.is_a? Hash
        @host = Host.new host
      elsif host.is_a? EtcdDiscovery::Host
        @host = host
      else
        raise TypeError, "host should be a Hash or a Etcd::Host, is a #{host.class}"
      end

      @service = service
      @state = :new
    end

    def register
      @state = :started
      config = EtcdDiscovery.config
      client = config.client
      value = @host.to_json
      key_name = "/services/#{@service}/#{@host.attributes['name']}"

      @thread = Thread.new {
        while @state == :started
          begin
            client.set(key_name, value: value, ttl: config.register_ttl)
          rescue => e
            logger.warn "Fail to set #{key_name}: #{e}, #{e.message}, #{e.class}"
          end
          sleep config.register_renew
        end
        logger.warn "Register '#{@service}' stopped"
      }
      self
    end

    def stop
      @state = :stopped
    end
  end
end
