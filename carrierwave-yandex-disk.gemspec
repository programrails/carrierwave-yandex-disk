
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carrierwave/yandex/disk/version'

Gem::Specification.new do |spec|
  spec.name          = 'carrierwave-yandex-disk'
  spec.version       = Carrierwave::Yandex::Disk::VERSION
  spec.authors       = ['programrails']
  spec.email         = ['programrails@yandex.ru']

  spec.summary       = 'Yandex.Disk integration for CarrierWave'.freeze
  spec.description   = 'CarrierWave storage for Yandex.Disk'.freeze
  spec.homepage      = 'https://github.com/programrails/carrierwave-yandex-disk'.freeze
  spec.license       = 'MIT'.freeze

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_dependency 'carrierwave', '>= 1.2'
  spec.add_dependency 'yandex-disk', '>= 0.0.8'
end
