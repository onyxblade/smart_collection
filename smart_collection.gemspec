require_relative './lib/smart_collection/version'

Gem::Specification.new do |spec|
  spec.name          = 'smart_collection'
  spec.version       = SmartCollection::VERSION
  spec.authors       = ['CicholGricenchos']
  spec.email         = ['cichol@live.cn']
  spec.homepage      = 'https://github.com/CicholGricenchos/smart_collection'
  spec.summary       = 'collections by rules'
  spec.description   = ''
  spec.license       = 'MIT'

  spec.files         = Dir.glob("lib/**/*.rb")

  spec.add_runtime_dependency 'associationist', '>= 0.1.8'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'rake'
end
