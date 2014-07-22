module CMSScanner
  # Controllers Container
  class Controllers < Array
    attr_reader :option_parser

    def initialize(option_parser = OptParseValidator::OptParser.new)
      @option_parser = option_parser
      # @option_parser.options_files << TODO
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

    # @param [ Hash ] opts
    def run(opts = {})
      parsed_options             = option_parser.results
      first.class.parsed_options = parsed_options

      if opts[:custom_views]
        opts[:custom_views].each { |v| first.formatter.views_directories << v }
      end

      redirect_output_to_file(parsed_options[:output]) if parsed_options[:output]

      each         { |c| c.before_scan(opts) }
      each         { |c| c.run(opts) }
      reverse.each { |c| c.after_scan(opts) }
    end
  end
end
