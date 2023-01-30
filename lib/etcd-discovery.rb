## Require files from etcd-discovery

require "etcd"
require "json"
require "logger"

dir = File.join File.dirname(__FILE__), "etcd-discovery"
Dir["#{dir}/*.rb"].sort.each do |file|
  require file
end

module EtcdDiscovery
  attr_writer :config

  def self.config
    @config ||= Config.new
  end

  def self.configure(&block)
    yield config if block
    config.validate
  end

  # For a cleaner API
  def self.get(service)
    Service.get(service)
  end

  def self.register(service, host)
    Registration.register(service, host)
  end
end
