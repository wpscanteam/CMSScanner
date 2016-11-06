# Gems
require 'cms_scanner'
require 'yajl/json_gem'
require 'addressable/uri'
require 'active_support/all'
# Standard Lib
require 'uri'
require 'time'
require 'readline'
require 'securerandom'
# Custom Libs
require 'cmsscan/target'
require 'cmsscan/controller'

Encoding.default_external = Encoding::UTF_8

# CMSScan
module CMSScan
  include CMSScanner

  APP_DIR = Pathname.new(__FILE__).dirname.join('..', 'app').expand_path
  # Not needed in this example
  # DB_DIR  = File.join(Dir.home, '.cmsscan', 'db')

  # Override, otherwise it would be returned as 'cms_scan'
  # doesn't really matter in this example.
  #
  # @return [ String ]
  def self.app_name
    'cmsscan'
  end
end

require "#{CMSScan::APP_DIR}/app"
