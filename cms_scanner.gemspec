lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'cms_scanner/version'

Gem::Specification.new do |s|
  s.name                  = 'cms_scanner'
  s.version               = CMSScanner::VERSION
  s.platform              = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.4'
  s.authors               = ['WPScanTeam']
  s.email                 = ['team@wpscan.org']
  s.summary               = 'CMS Scanner Framework (experimental)'
  s.description           = 'Framework to provide an easy way to implement CMS Scanners'
  s.homepage              = 'https://github.com/wpscanteam/CMSScanner'
  s.license               = 'MIT'

  s.files                 = Dir.glob('lib/**/*') + Dir.glob('app/**/*') + %w[LICENSE README.md]
  s.test_files            = []
  s.require_paths         = ['lib']

  s.add_dependency 'get_process_mem', '~> 0.2.4'
  s.add_dependency 'nokogiri', '~> 1.10.4'
  s.add_dependency 'opt_parse_validator', '~> 1.8.0'
  s.add_dependency 'public_suffix', '>= 3.0', '< 4.1'
  s.add_dependency 'ruby-progressbar', '~> 1.10.0'
  s.add_dependency 'typhoeus', '~> 1.3.0'
  s.add_dependency 'xmlrpc', '~> 0.3'
  s.add_dependency 'yajl-ruby', '~> 1.4.1' # Better JSON parser regarding memory usage

  # Required by get_process_mem
  if Gem.win_platform?
    s.add_dependency 'sys-proctable', '~> 1.2'
  else
    s.add_dependency 'ffi', '~> 1.11'
  end

  s.add_development_dependency 'bundler',             '>= 1.6'
  s.add_development_dependency 'coveralls',           '~> 0.8.0'
  s.add_development_dependency 'rake',                '~> 13.0'
  s.add_development_dependency 'rspec',               '~> 3.9.0'
  s.add_development_dependency 'rspec-its',           '~> 1.3.0'
  s.add_development_dependency 'rubocop',             '~> 0.76.0'
  s.add_development_dependency 'rubocop-performance', '~> 1.5.0'
  s.add_development_dependency 'simplecov',           '~> 0.16.1'
  s.add_development_dependency 'webmock',             '~> 3.7.0'
end
