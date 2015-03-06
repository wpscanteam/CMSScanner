# Gems
require 'opt_parse_validator'
require 'typhoeus'
require 'nokogiri'
require 'active_support/inflector'
require 'addressable/uri'
require 'public_suffix'
require 'ruby-progressbar'
# Standard Libs
require 'erb'
require 'uri'
require 'fileutils'
require 'pathname'
# Monkey Patches
require 'cms_scanner/typhoeus/response'
require 'cms_scanner/typhoeus/hydra'
require 'cms_scanner/public_suffix/domain'
# Custom Libs
require 'cms_scanner/helper'
require 'cms_scanner/errors/auth_errors'
require 'cms_scanner/cache/typhoeus'
require 'cms_scanner/target'
require 'cms_scanner/browser'
require 'cms_scanner/version'
require 'cms_scanner/controller'
require 'cms_scanner/controllers'
require 'cms_scanner/formatter'
require 'cms_scanner/finders'
require 'cms_scanner/vulnerability'

# Module
module CMSScanner
  APP_DIR = Pathname.new(__FILE__).dirname.join('..', 'app').expand_path
  NS      = self

  def self.included(base)
    remove_const(:NS)
    const_set(:NS, base)
    super(base)
  end

  # Number of requests performed to display at the end of the scan
  Typhoeus.on_complete do |response|
    self.total_requests += 1 unless response.cached?
  end

  def self.total_requests
    @@total_requests ||= 0
  end

  def self.total_requests=(value)
    @@total_requests = value
  end

  # Scan
  class Scan
    def initialize
      controllers << NS::Controller::Core.new

      yield self if block_given?
    end

    # @return [ Controllers ]
    def controllers
      @controllers ||= NS::Controllers.new
    end

    def run
      controllers.run
    rescue => e
      formatter.output('@scan_aborted',
                       reason: e.message,
                       trace: e.backtrace,
                       verbose: controllers.first.parsed_options[:verbose])
    ensure
      Browser.instance.hydra.abort

      formatter.beautify
    end

    # Used for convenience
    # @See Formatter
    def formatter
      controllers.first.formatter
    end

    # @return [ Hash ]
    def datastore
      controllers.first.datastore
    end
  end
end

require "#{CMSScanner::APP_DIR}/app"
