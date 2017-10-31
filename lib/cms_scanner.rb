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
# Monkey Patches
require 'cms_scanner/typhoeus/response'
require 'cms_scanner/typhoeus/hydra'
require 'cms_scanner/public_suffix/domain'
require 'cms_scanner/numeric'
# Custom Libs
require 'cms_scanner/helper'
require 'cms_scanner/exit_code'
require 'cms_scanner/errors/http'
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

  # Number of requests performed to display at the end of the scan
  Typhoeus.on_complete do |response|
    next if response.cached?

    self.total_requests += 1

    NS::Browser.instance.trottle!
  end

  # Module to be able to use these class methods when the CMSScanner
  # is included in another module
  module ClassMethods
    # @return [ Integer ]
    def total_requests
      @@total_requests ||= 0
    end

    # @param [ Integer ]
    def total_requests=(value)
      @@total_requests = value
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
    rescue StandardError => e
      @run_error = e

      formatter.output('@scan_aborted',
                       reason: e.message,
                       trace: e.backtrace,
                       verbose: controllers.first.parsed_options[:verbose])
    rescue Interrupt => e
      @run_error = e

      formatter.output('@scan_aborted', reason: 'Canceled by User')
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

      NS::ExitCode::ERROR
    end
  end
end

require "#{CMSScanner::APP_DIR}/app"
