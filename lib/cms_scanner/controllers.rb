require 'cms_scanner/controller'
require 'cms_scanner/controllers/core'
require 'cms_scanner/controllers/custom'

module CMSScanner
  # Controllers Container
  class Controllers < Array
    attr_reader :option_parser

    def initialize(option_parser = OptParseValidator::OptParser.new)
      @option_parser = option_parser
      # @option_parser.options_files << TODO
    end

    # @param [ CMSScanner::Controller::Base ] controller
    def <<(controller)
      options = controller.class.cli_options

      option_parser.add(*options) if options
      super(controller)
    end

    def run
      first.class.parsed_options = option_parser.results

      each         { |c| c.before_scan }
      each         { |c| c.run }
      reverse.each { |c| c.after_scan }
    end
  end
end
