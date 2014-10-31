# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'cms_scanner/version'

Gem::Specification.new do |s|
  s.name                  = 'cms_scanner'
  s.version               = CMSScanner::VERSION
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.0.0'
  s.authors               = ['WPScanTeam - Erwan le Rousseau']
  s.email                 = ['erwan.lr@gmail.com']
  s.summary               = 'Experimental CMSScanner'
  s.description           = 'Experimental CMSScanner'
  s.homepage              = 'https://github.com/wpscanteam/CMSScanner'
  s.license               = 'GPL-3.0'

  s.files                 = `git ls-files -z`.split("\x0")
  s.executables           = s.files.grep(/^bin\//) { |f| File.basename(f) }
  s.test_files            = s.files.grep(/^(test|spec|features)\//)
  s.require_path         = 'lib'

  s.add_dependency 'opt_parse_validator', '~> 0.0.4'
  s.add_dependency 'typhoeus', '~> 0.6.9'
  s.add_dependency 'nokogiri', '~> 1.6.3'
  s.add_dependency 'addressable', '~> 2.3.6'
  s.add_dependency 'activesupport', '~> 4.1'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'rspec-its'
  s.add_development_dependency 'bundler', '~> 1.6'
  s.add_development_dependency 'rubocop', '~> 0.27'
  s.add_development_dependency 'webmock', '>= 1.18'
  s.add_development_dependency 'simplecov', '~> 0.9'
end
