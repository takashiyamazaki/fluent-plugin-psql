# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-psql"
  gem.version       = "0.0.1"
  gem.authors       = ["takashiyamazaki"]
  gem.email         = ["mt.zakitaka@gmail.com"]
  gem.description   = %q{PostgreSQL plugin for Fluent event collector}
  gem.summary       = gem.description
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "fluentd"
  gem.add_development_dependency "pg"
  
  gem.add_runtime_dependency "fluentd"
  gem.add_runtime_dependency "pg"
end
