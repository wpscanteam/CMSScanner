module CMSScanner
  # Controllers Container
  class Controllers < Array
    attr_reader :option_parser

    def initialize(option_parser = OptParseValidator::OptParser.new(nil, 40))
      @option_parser = option_parser
    end

    # @param [ Controller::Base ] controller
    #
    # @retun [ Controllers ] self
    def <<(controller)
      options = controller.cli_options

      unless include?(controller)
        option_parser.add(*options) if options
        super(controller)
      end
      self
    end

    def run
      parsed_options             = option_parser.results
      first.class.parsed_options = parsed_options

      redirect_output_to_file(parsed_options[:output]) if parsed_options[:output]

      each(&:before_scan)
      each(&:run)
      reverse.each(&:after_scan)
    end
  end
end
