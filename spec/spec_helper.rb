$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'simplecov'
require 'rspec/its'
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

def count_files_in_dir(absolute_dir_path, files_pattern = '*')
  Dir.glob(File.join(absolute_dir_path, files_pattern)).count
end

require 'cms_scanner'
require 'shared_examples'

SPECS          = Pathname.new(__FILE__).dirname.to_s
CACHE          = File.join(SPECS, 'cache')
FIXTURES       = File.join(SPECS, 'fixtures')
FIXTURES_VIEWS = File.join(FIXTURES, 'views')
APP_VIEWS      = File.join(CMSScanner::APP_DIR, 'views')
