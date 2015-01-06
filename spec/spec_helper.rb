require "etcd-discovery"

require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development, :test)

EtcdDiscovery.config.register_renew = 0.5

