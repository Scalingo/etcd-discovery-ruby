Gem::Specification.new do |s|
  s.name        = 'etcd-discovery'
  s.version     = '0.0.3'
  s.date        = '2014-04-11'
  s.summary     = "Service discovery based on etcd"
  s.description = "Ruby implementation of a service discovery tool based on etcd"
  s.authors     = ["Léo Unbekandt"]
  s.email       = 'leo.unbekandt@appsdeck.eu'
  s.files       = [
    "lib/etcd-discovery.rb",
    "lib/etcd-discovery/client.rb",
    "lib/etcd-discovery/config.rb",
    "lib/etcd-discovery/host.rb",
    "lib/etcd-discovery/service.rb"
  ]
  s.homepage    =
    'http://github.com/Appsdeck/etcd-discovery-ruby'
  s.license       = 'BSD'
  s.add_dependency "etcd"
end
