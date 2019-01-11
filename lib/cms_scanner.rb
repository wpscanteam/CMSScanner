# Gems
require 'typhoeus'
require 'nokogiri'
require 'yajl/json_gem'
require 'public_suffix'
require 'addressable/uri'
require 'ruby-progressbar'
require 'opt_parse_validator'
require 'active_support/concern'
require 'active_support/inflector'
# Standard Libs
require 'erb'
require 'uri'
require 'fileutils'
require 'pathname'
require 'timeout'
require 'xmlrpc/client'
# Monkey Patches
require 'cms_scanner/typhoeus/response' # Adds a Response#html using Nokogiri to parse the body
require 'cms_scanner/typhoeus/hydra' # https://github.com/typhoeus/typhoeus/issues/439
require 'cms_scanner/public_suffix/domain' # Adds a Domain#match method and logic, used in scope stuff
require 'cms_scanner/numeric' # Adds a Numeric#bytes_to_human
require 'cms_scanner/progressbar_null_output'
# Custom Libs
require 'cms_scanner/helper'
require 'cms_scanner/exit_code'
require 'cms_scanner/errors/http'
require 'cms_scanner/errors/scan'
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

# Module
module CMSScanner
  APP_DIR = Pathname.new(__FILE__).dirname.join('..', 'app').expand_path
  NS      = self

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

  # Scan
  class Scan
    attr_reader :run_error

    def initialize
      controllers << NS::Controller::Core.new

      exit_hook

      yield self if block_given?
    end

    # @return [ Controllers ]
    def controllers
      @controllers ||= NS::Controllers.new
    end

    def run
      controllers.run
    rescue OptParseValidator::NoRequiredOption => e
      @run_error = e

      formatter.output('@usage', msg: e.message)
    rescue StandardError, SignalException => e
      @run_error = e

      formatter.output('@scan_aborted',
                       reason: e.is_a?(Interrupt) ? 'Canceled by User' : e.message,
                       trace: e.backtrace,
                       verbose: controllers.first.parsed_options[:verbose] ||
                                run_error_exit_code == NS::ExitCode::EXCEPTION)
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

    # Hook to be able to have an exit code returned
    # depending on the findings / errors
    def exit_hook
      at_exit do
        exit(run_error_exit_code) if run_error

        controller = controllers.first

        # The parsed_option[:url] must be checked to avoid raising erros when only -h/-v are given
        exit(NS::ExitCode::VULNERABLE) if controller.parsed_options[:url] && controller.target.vulnerable?
        exit(NS::ExitCode::OK)
      end
    end

    # @return [ Integer ] The exit code related to the run_error
    def run_error_exit_code
      return NS::ExitCode::CLI_OPTION_ERROR if run_error.is_a?(OptParseValidator::Error) ||
                                               run_error.is_a?(OptionParser::ParseError)

      return NS::ExitCode::INTERRUPTED if run_error.is_a?(Interrupt)

      return NS::ExitCode::ERROR if run_error.is_a?(NS::Error) || run_error.is_a?(CMSScanner::Error)

      NS::ExitCode::EXCEPTION
    end
  end
end

require "#{CMSScanner::APP_DIR}/app"
