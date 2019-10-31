lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'cmsscan/version'

Gem::Specification.new do |s|
  s.name                  = 'cmsscan'
  s.version               = CMSScan::VERSION
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.3'
  s.authors               = ['WPScanTeam']
  s.date                  = Time.now.utc.strftime('%Y-%m-%d')
  s.email                 = ['team@wpscan.org']
  s.summary               = 'CMSScan Gem Example'
  s.description           = 'CMSScanner Implementation Example'
  s.homepage              = 'https://github.com/wpscanteam/CMSScanner'
  s.license               = 'MIT'

  s.files                 = Dir.glob('lib/**/*') + Dir.glob('app/**/*')
  s.test_files            = []
  s.executables           = ['cmsscan']
  s.require_paths         = ['lib']

  s.add_dependency 'cms_scanner', '~> 0.6.2'

  s.add_development_dependency 'bundler',             '>= 1.6'
  s.add_development_dependency 'coveralls',           '~> 0.8.0'
  s.add_development_dependency 'memory_profiler',     '~> 0.9.13'
  s.add_development_dependency 'rake',                '~> 13.0'
  s.add_development_dependency 'rspec',               '~> 3.9.0'
  s.add_development_dependency 'rspec-its',           '~> 1.3.0'
  s.add_development_dependency 'rubocop',             '~> 0.76.0'
  s.add_development_dependency 'rubocop-performance', '~> 1.5.0'
  s.add_development_dependency 'simplecov',           '~> 0.16.1'
  s.add_development_dependency 'stackprof',           '~> 0.2.12'
  s.add_development_dependency 'webmock',             '~> 3.7.0'
end
