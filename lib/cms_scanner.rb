# frozen_string_literal: true

# Gems
require 'typhoeus'
require 'nokogiri'
require 'yajl/json_gem'
require 'public_suffix'
require 'addressable/uri'
require 'get_process_mem'
require 'ruby-progressbar'
require 'opt_parse_validator'
require 'active_support/concern'
require 'active_support/inflector'
# Standard Libs
require 'erb'
require 'uri'
require 'fileutils'
require 'pathname'
require 'socket'
require 'timeout'
require 'xmlrpc/client'
# Monkey Patches/Fixes
require 'cms_scanner/typhoeus/response' # Adds a Response#html using Nokogiri to parse the body
require 'cms_scanner/typhoeus/hydra' # https://github.com/typhoeus/typhoeus/issues/439
require 'cms_scanner/public_suffix/domain' # Adds a Domain#match method and logic, used in scope stuff
require 'cms_scanner/numeric' # Adds a Numeric#bytes_to_human
# Custom Libs
require 'cms_scanner/scan'
require 'cms_scanner/parsed_cli'
require 'cms_scanner/helper'
require 'cms_scanner/exit_code'
require 'cms_scanner/errors'
require 'cms_scanner/cache/typhoeus'
require 'cms_scanner/target'
require 'cms_scanner/browser'
require 'cms_scanner/version'
require 'cms_scanner/controller'
require 'cms_scanner/controllers'
require 'cms_scanner/formatter'
require 'cms_scanner/references'
require 'cms_scanner/finders'
require 'cms_scanner/vulnerability'
require 'cms_scanner/progressbar_null_output'

# Module
module CMSScanner
  APP_DIR = Pathname.new(__FILE__).dirname.join('..', 'app').expand_path
  NS      = self

  # Avoid memory leak when using Hydra, see https://github.com/typhoeus/typhoeus/issues/562
  # Requests are still cached via the provided Cache system
  Typhoeus::Config.memoize = false

  # Number of requests performed and data sent/received to display at the end of the scan
  Typhoeus.on_complete do |response|
    self.cached_requests += 1 if response.cached?

    next if response.cached?

    self.total_requests += 1
    self.total_data_sent += response.request_size
    self.total_data_received += response.size

    NS::Browser.instance.trottle!
  end

  # Module to be able to use these class methods when the CMSScanner
  # is included in another module
  module ClassMethods
    # @return [ Integer ]
    def cached_requests
      @@cached_requests ||= 0
    end

    # @param [ Integer ] value
    def cached_requests=(value)
      @@cached_requests = value
    end

    # @return [ Integer ]
    def total_requests
      @@total_requests ||= 0
    end

    # @param [ Integer ] value
    def total_requests=(value)
      @@total_requests = value
    end

    # @return [ Integer ]
    def total_data_sent
      @@total_data_sent ||= 0
    end

    # @param [ Integer ] value
    def total_data_sent=(value)
      @@total_data_sent = value
    end

    # @return [ Integer ]
    def total_data_received
      @@total_data_received ||= 0
    end

    # @param [ Integer ] value
    def total_data_received=(value)
      @@total_data_received = value
    end

    # @return [ Integer ] The memory at the start of the scan (when Scan.new), in B
    def start_memory
      @@start_memory ||= 0
    end

    # @param [ Integer ] value
    def start_memory=(value)
      @@start_memory = value
    end

    # The lowercase name of the scanner
    # Mainly used in directory paths like the default cookie-jar file and
    # path to load the cli options from files
    #
    # @return [ String ]
    def app_name
      to_s.underscore
    end
  end

  extend ClassMethods

  def self.included(base)
    remove_const(:NS)
    const_set(:NS, base)

    base.extend(ClassMethods)
    super(base)
  end
end

require "#{CMSScanner::APP_DIR}/app"
