# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'cms_scanner/version'

Gem::Specification.new do |s|
  s.name                  = "cms_scanner"
  s.version               = CMSScanner::VERSION
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.0.0'
  s.authors               = ['WPScanTeam - Erwan le Rousseau']
  s.email                 = ["erwan.lr@gmail.com"]
  s.summary               = %q{Experimental CMSScanner}
  s.description           = %q{Experimental CMSScanner}
  s.homepage              = 'https://github.com/wpscanteam/CMSScanner'
  s.license               = 'MIT'

  s.files                 = `git ls-files -z`.split("\x0")
  s.executables           = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files            = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths         = ['lib']

  s.add_dependency 'opt_parse_validator'
  s.add_dependency 'typhoeus'
  s.add_dependency 'nokogiri'
  s.add_dependency 'addressable'
  s.add_dependency 'activesupport'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.14'
  s.add_development_dependency 'bundler', '~> 1.5'
  s.add_development_dependency 'rubocop', '~> 0.18'
  s.add_development_dependency 'simplecov', '~> 0.8'
end
