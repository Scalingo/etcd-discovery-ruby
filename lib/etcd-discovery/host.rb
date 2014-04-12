module EtcdDiscovery
  class InvalidHost < RuntimeError
  end

  class Host
    attr_accessor :attributes

    def initialize(arg)
      if arg.is_a? Etcd::Node
        @attributes = JSON.parse arg.value
      elsif arg.is_a? Hash
        @attributes = arg
      else
        raise TypeError, "requires a Etcd::Node or a Hash, not a #{arg.class}"
      end
      if !attributes.has_key? 'name' or !attributes.has_key? 'port'
        raise InvalidHost, "attributes 'name' and 'port' should be defined"
      end
      attributes['user'] = "" if attributes['user'].nil?
      attributes['password'] = "" if attributes['password'].nil?
      attributes['scheme'] = "http" if attributes['scheme'].nil?
    end

    def to_json
      attributes.to_json
    end

    def to_uri
      a = attributes # Shorten name
      URI("#{a['scheme']}://#{a['user']}:#{a['password']}@#{a['name']}:#{a['port']}")
    end

    def to_s
      self.to_uri.to_s
    end
  end
end
