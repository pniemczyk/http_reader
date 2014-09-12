# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'http_reader/version'

Gem::Specification.new do |spec|
  spec.name          = 'http_reader'
  spec.version       = HttpReader::VERSION
  spec.authors       = ['Paweł Niemczyk']
  spec.email         = ['pniemczyk@o2.pl']
  spec.description   = %q{Read page body and parse to specific data}
  spec.summary       = %q{Read page body and parse to specific data}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'coveralls'

  spec.post_install_message = 'Have fun !'
end
