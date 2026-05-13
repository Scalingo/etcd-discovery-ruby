Gem::Specification.new do |s|
  s.name = "etcd-discovery"
  s.version = "1.2.1"
  s.summary = "Service discovery based on etcd"
  s.description = "Ruby implementation of a service discovery tool based on etcd"
  s.authors = ["Léo Unbekandt"]
  s.email = "leo@scalingo.com"
  s.files = [
    "lib/etcd-discovery.rb",
    "lib/etcd-discovery/client.rb",
    "lib/etcd-discovery/config.rb",
    "lib/etcd-discovery/host.rb",
    "lib/etcd-discovery/service.rb",
    "lib/etcd-discovery/registrar.rb",
    "lib/etcd-discovery/registration.rb",
    "spec/spec_helper.rb",
    "spec/etcd-discovery/registrar_spec.rb"
  ]
  s.metadata = {"source_code_uri" => "https://github.com/Scalingo/etcd-discovery-ruby"}
  s.homepage = "https://rubygems.org/gems/etcd-discovery"
  s.licenses = ["Apache-2.0"]

  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  s.add_dependency "etcd"
end
