class Hash
  def capitalize_keys
    new_hash = {}
    self.each do |k,v|
      new_hash[k.to_s.capitalize] = v
    end
    return new_hash
  end
end

module EtcdDiscovery
  class Host
    attr_accessor :hostname, :port, :user, :password, :scheme

    def initialize(arg)
      if arg.is_a? Etcd::Node
        params = JSON.parse arg.value
      elsif arg.is_a? Hash
        params = arg.capitalize_keys
      else
        raise TypeError, "requires a Etcd::Node or a Hash, not a #{arg.class}"
      end
      @hostname = params['Name']
      @port = params['Port']
      @user = params['User']
      @password = params['Password']
      @scheme = params['Scheme'] || "http"

      if @hostname.nil? or @hostname.empty?
        @hostname = Socket.gethostname
      end
    end

    def to_json
      {"Name" => hostname, "Port" => port, "Scheme" => scheme, "User" => user, "Password" => password}.to_json
    end

    def to_uri
      URI("#{scheme}://#{user}:#{password}@#{hostname}:#{port}")
    end
  end
end
