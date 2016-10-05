# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'cms_scanner/version'

Gem::Specification.new do |s|
  s.name                  = 'cms_scanner'
  s.version               = CMSScanner::VERSION
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.2.2'
  s.authors               = ['WPScanTeam']
  s.email                 = ['team@wpscan.org']
  s.summary               = 'CMS Scanner Framework (experimental)'
  s.description           = 'Framework to provide an easy way to implement CMS Scanners'
  s.homepage              = 'https://github.com/wpscanteam/CMSScanner'
  s.license               = 'MIT'

  s.files                 = `git ls-files -z`.split("\x0").reject do |file|
    file =~ %r{^(?:
      spec\/.*
      |Gemfile
      |Rakefile
      |\.rspec
      |\.gitignore
      |\.rubocop.yml
      |\.travis.yml
      )$}x
  end
  s.test_files            = []
  s.executables           = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_path          = 'lib'

  s.add_dependency 'typhoeus', '~> 1.1.0'
  s.add_dependency 'nokogiri', '~> 1.6.8.1'
  s.add_dependency 'yajl-ruby', '~> 1.2.1' # Better JSON parser regarding memory usage
  s.add_dependency 'addressable', '~> 2.4.0'
  s.add_dependency 'activesupport', '~> 5.0.0.1'
  s.add_dependency 'public_suffix', '~> 1.5'
  s.add_dependency 'ruby-progressbar', '~> 1.8.1'
  s.add_dependency 'opt_parse_validator', '~> 0.0.13.2'

  s.add_development_dependency 'rake', '~> 11.3.0'
  s.add_development_dependency 'rspec', '~> 3.5.0'
  s.add_development_dependency 'rspec-its', '~> 1.2.0'
  s.add_development_dependency 'bundler', '~> 1.6'
  s.add_development_dependency 'rubocop', '~> 0.43.0'
  s.add_development_dependency 'webmock', '~> 1.22'
  s.add_development_dependency 'simplecov', '~> 0.12.0'
end
