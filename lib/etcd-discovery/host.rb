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
      if !attributes.has_key?("name") || !attributes.has_key?("ports")
        raise InvalidHost, "attributes 'name' and 'ports' should be defined"
      end
      attributes["user"] = "" if attributes["user"].nil?
      attributes["password"] = "" if attributes["password"].nil?
    end

    def to_json
      attributes.to_json
    end

    def to_uri(schemes = ["https", "http"])
      schemes = Array(schemes)

      scheme = schemes.find { |s| attributes["ports"][s] }
      raise "No valid scheme found" unless scheme

      if attributes["user"].nil? || attributes["user"].empty?
        return URI("#{scheme}://#{attributes["name"]}:#{attributes["ports"][scheme]}")
      end

      URI("#{scheme}://#{attributes["user"]}:#{attributes["password"]}@#{attributes["name"]}:#{attributes["ports"][scheme]}")
    end

    def to_private_uri(schemes = ["https", "http"])
      a = attributes
      if a["private_hostname"].empty?
        return to_uri(schemes)
      end
      schemes = [schemes] if !schemes.is_a?(Array)
      scheme = schemes.find { |s|
        !a["private_ports"][s].nil?
      }

      if a["user"].nil? || a["user"] == ""
        URI("#{scheme}://#{a["private_hostname"]}:#{a["private_ports"][scheme]}")
      else
        URI("#{scheme}://#{a["user"]}:#{a["password"]}@#{a["private_hostname"]}:#{a["private_ports"][scheme]}")
      end
    end

    def set_credentials(user, password)
      @attributes["user"] = user
      @attributes["password"] = password
    end

    def to_s
      uri = to_uri
      if uri.userinfo
        user, _password = uri.userinfo.split(":", 2)
        uri.userinfo = "#{user}:REDACTED"
      end
      uri.to_s
    end
  end
end
