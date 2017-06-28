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
hosts = EtcdDiscovery.get("service").all
hosts.each do |h|
  puts h.to_uri
end
```

### Get the service plublic uri

```ruby
EtcdDiscovery.get('service').to_uri
```

### Get the private_uri to one of the nodes

```ruby
EtcdDiscovery.get('service').one.to_uri
```

### Register a service

This will be run in a secondary thread.

```ruby
EtcdDiscovery.register "service", {
  'name' => "hostname",                         # Mandatory: The hostname of the service
  'ports' => {                                  # Mandatory: The ports openned by the service
    'http'=> '80',
    'https' => '443'
  },
  'user' => "testuser",                         # Optionnal: If your service use basic auth: the username to access your service
  'password' => "secret",                       # Optionnal: If your service use basic auth: the password to access your service
  'public' => true,                             # Optionnal: Is your service accessible via an external network (or via a load balancer). Setting this to true will enable credentials synchronisation.
  'critical' => true,                           # Optionnal: Is your service critical? This is just a tag and have no impact on the registration process
  'private_hostname' => 'my-host.internal.com', # Optionnal: The hostname of the service in the private network
  'private_ports' => {                          # Optionnal: The ports of the service in the private network
    'http' => '8080',
    'https' => '80443'
  }
}
```

### Listen to credentials change

When a service is public, user and password are synced accross all the hosts of the service.

You can fetch the current user and password using the object returned by the register method.

```ruby
registration = EtcdDiscovery.register service, host

registration.user     # The current user (it can change at any time)
registration.password # The current password (it can change at any time)
```
