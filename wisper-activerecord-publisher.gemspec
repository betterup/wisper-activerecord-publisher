# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wisper/activerecord/publisher/version'

Gem::Specification.new do |spec|
  spec.name          = 'wisper-activerecord-publisher'
  spec.version       = Wisper::Activerecord::Publisher::VERSION
  spec.authors       = ['BetterUp Developers']
  spec.email         = ['developers@betterup.co']

  spec.summary       = 'Publish wisper events for activerecord model lifecycle'
  spec.homepage      = 'https://github.com/betterup/wisper-activerecord-publisher'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'wisper'
  spec.add_runtime_dependency 'activerecord', '>= 5.0'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency "sqlite3"
end
