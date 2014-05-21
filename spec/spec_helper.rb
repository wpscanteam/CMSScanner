# $LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
# $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app'))

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

# See http://betterspecs.org/
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require 'cms_scanner'
require 'shared_examples'

FIXTURES       = Pathname.new(__FILE__).dirname.join('fixtures').to_s
FIXTURES_VIEWS = File.join(FIXTURES, 'views')
APP_VIEWS      = Pathname.new(CMSScanner::APP_DIR).join('views').to_s
