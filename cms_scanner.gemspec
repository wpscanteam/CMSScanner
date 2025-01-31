lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'cms_scanner/version'

Gem::Specification.new do |s|
  s.name                  = 'cms_scanner'
  s.version               = CMSScanner::VERSION
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = '>= 3.0'
  s.authors               = ['WPScanTeam']
  s.email                 = ['contact@wpscan.com']
  s.summary               = 'CMS Scanner Framework (experimental)'
  s.description           = 'Framework to provide an easy way to implement CMS Scanners'
  s.homepage              = 'https://github.com/wpscanteam/CMSScanner'
  s.license               = 'MIT'

  s.files                 = Dir.glob('lib/**/*') + Dir.glob('app/**/*') + %w[LICENSE README.md]
  s.test_files            = []
  s.require_paths         = ['lib']

  s.add_dependency 'ethon', '>= 0.14', '< 0.17' # https://github.com/typhoeus/ethon/issues/185
  s.add_dependency 'get_process_mem', '>= 0.2.5', '< 1.1.0'
  s.add_dependency 'nokogiri', '~> 1.16'
  s.add_dependency 'opt_parse_validator', '~> 1.10.0'
  s.add_dependency 'public_suffix', '>= 4.0.3', '< 6.1'
  s.add_dependency 'ruby-progressbar', '>= 1.10', '< 1.14'
  s.add_dependency 'typhoeus', '>= 1.3', '< 1.5'
  s.add_dependency 'xmlrpc', '~> 0.3'
  s.add_dependency 'yajl-ruby', '~> 1.4.1' # Better JSON parser regarding memory usage

  s.add_dependency 'sys-proctable', '>= 1.2.2', '< 1.4.0' # Required by get_process_mem for Windows OS.

  # Fixes warning: ostruct was loaded from the standard library
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.3')
    s.add_dependency('ostruct', '~> 0.6')
  end

  s.add_development_dependency 'bundler',             '>= 1.6'
  s.add_development_dependency 'rake',                '~> 13.0'
  s.add_development_dependency 'rspec',               '~> 3.13.0'
  s.add_development_dependency 'rspec-its',           '~> 2.0.0'
  s.add_development_dependency 'rubocop',             '~> 1.71.0'
  s.add_development_dependency 'rubocop-performance', '~> 1.19.1'
  s.add_development_dependency 'simplecov',           '~> 0.22.0'
  s.add_development_dependency 'simplecov-lcov',      '~> 0.8.0'
  s.add_development_dependency 'webmock',             '~> 3.24.0'
end
