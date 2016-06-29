Gem::Specification.new do |s|
  s.name        = 'etcd-discovery'
  s.version     = '0.1.3'
  s.date        = '2016-06-29'
  s.summary     = "Service discovery based on etcd"
  s.description = "Ruby implementation of a service discovery tool based on etcd"
  s.authors     = ["Léo Unbekandt"]
  s.email       = 'leo.unbekandt@scalingo.com'
  s.files       = [
    "lib/etcd-discovery.rb",
    "lib/etcd-discovery/client.rb",
    "lib/etcd-discovery/config.rb",
    "lib/etcd-discovery/host.rb",
    "lib/etcd-discovery/service.rb",
    "lib/etcd-discovery/registrar.rb",
    "spec/spec_helper.rb",
    "spec/etcd-discovery/registrar_spec.rb",
  ]
  s.homepage    =
    'http://github.com/Scalingo/etcd-discovery-ruby'
  s.license       = 'BSD'
  s.add_dependency "etcd"
end
