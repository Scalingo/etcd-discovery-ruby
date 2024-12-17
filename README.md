etcd-discovery-ruby
==================

Ruby gem implementing etcd-discovery

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

### Get the service public uri

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
  'ports' => {                                  # Mandatory: The ports opened by the service
    'http'=> '80',
    'https' => '443'
  },
  'user' => "testuser",                         # Optional: If your service use basic auth: the username to access your service
  'password' => "secret",                       # Optional: If your service use basic auth: the password to access your service
  'public' => true,                             # Optional: Is your service accessible via an external network (or via a load balancer). Setting this to true will enable credentials synchronization.
  'critical' => true,                           # Optional: Is your service critical? This is just a tag and have no impact on the registration process
  'private_hostname' => 'my-host.internal.com', # Optional: The hostname of the service in the private network
  'private_ports' => {                          # Optional: The ports of the service in the private network
    'http' => '8080',
    'https' => '80443'
  }
}
```

### Listen to credentials change

When a service is public, user and password are synced across all the hosts of the service.

You can fetch the current user and password using the object returned by the register method.

```ruby
registration = EtcdDiscovery.register service, host

registration.user     # The current user (it can change at any time)
registration.password # The current password (it can change at any time)
```

### Release a New Version
Bump new version number in:
- `CHANGELOG.md`
- `README.md`
- `etcd-discovery.gemspec`
Commit, tag and create a new release:

```bash
version="1.1.1"

git switch --create release/${version}
git add CHANGELOG.md README.md etcd-discovery.gemspec
git commit -m "Bump v${version}"
git push --set-upstream origin release/${version}
gh pr create --reviewer=leo-scalingo --title "$(git log -1 --pretty=%B)"
```

Once the pull request merged, you can tag the new release.

```bash
git tag v${version}
git push origin master v${version}
gh release create v${version}
```

The title of the release should be the version number and the text of the release is the same as the changelog.
