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
      if !attributes.has_key?('name') or !attributes.has_key?('ports')
        raise InvalidHost, "attributes 'name' and 'ports' should be defined"
      end
      attributes['user'] = "" if attributes['user'].nil?
      attributes['password'] = "" if attributes['password'].nil?
    end

    def to_json
      attributes.to_json
    end

    def to_uri(scheme = "http")
      a = attributes # Shorten name
      if a['user'].empty?
        URI("#{scheme}://#{a['name']}:#{a['ports'][scheme]}")
      else
        URI("#{scheme}://#{a['user']}:#{a['password']}@#{a['name']}:#{a['ports'][scheme]}")
      end
    end

    def to_s
      self.to_uri.to_s
    end
  end
end
