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
      parsed_options             = option_parser.results
      first.class.parsed_options = parsed_options
      first.class.target         = Target.new(parsed_options[:url])

      each         { |c| c.before_scan }
      each         { |c| c.run }
      reverse.each { |c| c.after_scan }
    end
  end
end
