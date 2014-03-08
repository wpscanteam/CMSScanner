# Gems
require 'opt_parse_validator'
require 'typhoeus'
require 'nokogiri'
# Custom Libs
require 'cms_scanner/target'
require 'cms_scanner/browser'
require 'cms_scanner/version'
require 'cms_scanner/controllers'
require 'cms_scanner/controller'
require 'cms_scanner/controller/core'
require 'cms_scanner/controller/custom'

# Module
module CMSScanner
  # Scan
  class Scan
    def initialize
      controllers << Controller::Core.new <<
                     Controller::Custom.new
    end

    def controllers
      @controllers ||= Controllers.new
    end

    def run
      parsed_options = controllers.option_parser.results

      Controller::Core.parsed_options = parsed_options
      Controller::Core.target         = Target.new(parsed_options[:url])

      controllers.run
    end
  end
end
