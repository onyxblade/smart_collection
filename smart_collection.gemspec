Gem::Specification.new do |spec|
  spec.name          = 'smart_collection'
  spec.version       = '0.0.1'
  spec.authors       = ['CicholGricenchos']
  spec.email         = ['cichol@live.cn']
  spec.homepage      = 'https://github.com/CicholGricenchos/smart_collection'
  spec.summary       = ''
  spec.description   = ''
  spec.license       = 'MIT'

  spec.files         = Dir.glob("lib/**/*.rb")

  spec.add_runtime_dependency 'activerecord', '>5'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'database_cleaner'
end
