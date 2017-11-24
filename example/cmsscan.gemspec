# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'cmsscan/version'

Gem::Specification.new do |s|
  s.name                  = 'cmsscan'
  s.version               = CMSScan::VERSION
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.1.0'
  s.authors               = ['WPScanTeam']
  s.date                  = Time.now.utc.strftime('%Y-%m-%d')
  s.email                 = ['team@wpscan.org']
  s.summary               = 'CMSScan Gem Example'
  s.description           = 'CMSScanner Implementation Example'
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

  s.add_dependency 'cms_scanner', '~> 0.0.38.1'

  # Already required by CMSScanner, so version restrictions loosen
  s.add_dependency 'activesupport', '~> 5.1'
  s.add_dependency 'yajl-ruby', '~> 1.3'

  s.add_development_dependency 'bundler', '~> 1.6'
  s.add_development_dependency 'coveralls', '~> 0.8.0'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rspec', '~> 3.7.0'
  s.add_development_dependency 'rspec-its', '~> 1.2.0'
  s.add_development_dependency 'rubocop', '~> 0.51.0'
  s.add_development_dependency 'simplecov', '~> 0.14.0' # Can't update to 0.15 as it breaks coveralls dep
  s.add_development_dependency 'webmock', '~> 3.1.0'
end
