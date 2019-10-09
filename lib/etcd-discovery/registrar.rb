require 'securerandom'

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
    attr_reader :watcher
    attr_reader :host
    attr_reader :service
    attr_reader :user
    attr_reader :password

    def initialize(service, host)
      @logger = Logger.new($stdout)

      if host.is_a? Hash
        @host = Host.new host.merge('service_name' => service, 'uuid' => SecureRandom.uuid)
      elsif host.is_a? EtcdDiscovery::Host
        @host = host
      else
        raise TypeError, "host should be a Hash or a Etcd::Host, is a #{host.class}"
      end

      @service = EtcdDiscovery::Service.new service_params
      @state = :new
      @user     = @host.attributes['user']
      @password = @host.attributes['password']
    end

    def register
      if @state == :started
        @logger.warn "#{@service} is already registered"
        return
      end

      @state = :started

      service_value = @service.to_json

      # Do not start credentials synchro if the service is not public or has no credentials
      if @service.attributes['public'] && (@service.attributes['user'].present? || @service.attributes['password'].present?)
        @watcher = Thread.new {
          @logger.warn "Watcher #{@service.attributes['name']} started"
          index = 0
          while @state == :started
            begin
              resp = client.watch service_key, { index: index }
            rescue => e
              @logger.warn "Fail to watch #{service_key}: #{e}, #{e.message}, #{e.class}"
              next
            end
            value = JSON.parse resp.node.value
            @user = value['user']
            @password = value['password']
            @host.set_credentials user, password
            @service.set_credentials user, password
            index = resp.etcd_index
          end
        }
      end

      client.set(service_key, value: service_value)
      @thread = Thread.new {
        @logger.warn "Register '#{@service}' started"
        while @state == :started
          value = @host.to_json
          begin
            client.set(host_key, value: value, ttl: config.register_ttl)
          rescue => e
            @logger.warn "Fail to set #{service_key}: #{e}, #{e.message}, #{e.class}"
          end
          sleep config.register_renew
        end
        @logger.warn "Register '#{@service}' stopped"
      }


      return self
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

    def host_key
      "/services/#{@service.attributes['name']}/#{@host.attributes['uuid']}"
    end

    def service_key
      "/services_infos/#{@service.attributes['name']}"
    end

    def service_params
      params = {
        'name' =>     host.attributes['service_name'],
        'critical' => host.attributes['critical'],
        'user' =>     host.attributes['user'],
        'password' => host.attributes['password'],
        'public' =>   host.attributes['public']
      }
      params['hostname'] = host.attributes['name']if params['public']
      params['ports'] = host.attributes['ports']  if params['public']
      return params
    end
  end
end
