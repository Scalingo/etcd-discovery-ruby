require "etcd-discovery"

require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development, :test)

EtcdDiscovery.config.register_renew = 0.1

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: false)

require_relative "./etcd_helper"

RSpec.configure do |config|
  config.include(EtcdHelper)
end
