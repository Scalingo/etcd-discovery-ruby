module EtcdDiscovery
  class InvalidStateError < StandardError
    def initialize(current, expected)
      @current = current
      @expected = expected
    end

    def message
      "Registrar is #{@current}, expected #{@expected}"
    end
  end

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
      if @state == :started
        logger.warn "#{@service} is already registered"
        return
      end

      @state = :started
      value = @host.to_json

      @thread = Thread.new {
        @logger.warn "Register '#{@service}' started"
        while @state == :started
          begin
            client.set(key, value: value, ttl: config.register_ttl)
          rescue => e
            @logger.warn "Fail to set #{key}: #{e}, #{e.message}, #{e.class}"
          end
          sleep config.register_renew
        end
        @logger.warn "Register '#{@service}' stopped"
      }
      self
    end

    def stop
      raise InvalidStateError.new(@state, :started) if @state != :started
      @logger.debug "Set state to :stopped"
      @state = :stopped
      @logger.debug "Delete #{key}"
      client.delete(key)
    end

    def client
      config.client
    end

    def config
      EtcdDiscovery.config
    end

    def key
      "/services/#{@service}/#{@host.attributes['name']}"
    end
  end
end
