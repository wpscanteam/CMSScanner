$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

FIXTURES       = Pathname.new(__FILE__).dirname.join('fixtures').to_s
FIXTURES_VIEWS = File.join(FIXTURES, 'views')

require 'simplecov'
require 'webmock/rspec'

if ENV['TRAVIS']
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
end

SimpleCov.start do
  add_filter '/spec/'
  add_filter 'helper'
end

require 'cms_scanner'
# require 'shared_examples'
