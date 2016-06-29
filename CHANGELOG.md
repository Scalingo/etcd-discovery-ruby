## v0.1.3 - 29 Jun 2016

* `EtcdDiscovery::Hosts#to_uri` returns https in priority, then http

## v0.0.12 - 7 Jan 2014

Stop registration is now possible

```ruby
r = EtcdDiscovery.new(service, host).register
…
r.stop
```

## v0.0.11 - 3 Aug 2014

Service as a Hash of interfaces with its port

## v0.0.10 - 29 May 2014

Use logger instead of simple puts for registering errors

## v0.0.9 - 22 May 2014

Don't stop registering after failing to set a key

## v0.0.8 - 30 April 2014

Generate clean URL when no authorization is required
Fix registration according to 0.0.7

## v0.0.7 - 12 April 2014

Fix host class, remove instance variables

## v0.0.6 - 12 April 2014

Don't use environment to setup SSL parameters

## v0.0.5 - 11 April 2014

lower case JSON, use hash instead of attributes for host

## v0.0.4 - 11 April 2014

Allow host to specify scheme

## v0.0.3 - 11 April 2014

Add etcd as gem dependency

## v0.0.2 - 11 April 2014

Change gemspec description

## v0.0.1 - 11 April 2014

Basic implementation without tests

```
EtcdDiscovery.configure
EtcdDiscovery.get
EtcdDiscovery.register
```
