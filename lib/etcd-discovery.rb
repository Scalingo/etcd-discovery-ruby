## Require files from etcd-discovery

require 'etcd'
require 'json'

dir = File.join File.dirname(__FILE__), "etcd-discovery"
Dir["#{dir}/*.rb"].each do |file|
  require file
end

module EtcdDiscovery
  attr_writer :config

  def self.config
    @config ||= Config.new
  end

  def self.configure(&block)
    yield config if block_given?
    config.validate
  end

  # For a cleaner API
  def self.get(service)
    Service.get(service)
  end

  def self.register(service, host)
    Thread.new { Service.register(service, host) }
  end
end
