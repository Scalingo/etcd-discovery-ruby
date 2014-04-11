etcd-discovery-ruby
==================

Ruby gem implementing go Appsdeck/etcd-discovery

### Configure etcd client

Default client isn't using SSL and tries http://localhost:4001

```ruby
EtcdDiscovery.configure do |config|
  config.use_ssl = true                            # Default: false
  config.cacert = "/etc/ssl/cacert.pem"            # nil
  config.ssl_key = "/etc/ssl/service/private.key"  # nil
  config.ssl_cert = "/etc/ssl/service/public.cert" # nil
  config.host = "myhost"                           # Default: "localhost"
  config.port = 4002                               # Default: 4001
  config.register_ttl = 5                          # Default: 10
  config.register_renew = 4                        # Default: 8
end
```

### Get hosts for a particular service

```ruby
hosts = EtcdDiscovery.get "service"
hosts.each do |h|
  puts h.to_uri
end
```

### Register a service

This will be run in a secondary thread.

```ruby
EtcdDiscovery.register "service", name: "hostname", port: "12345", user: "testuser", password: "secret"
```

