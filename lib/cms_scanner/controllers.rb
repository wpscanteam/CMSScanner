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

    # TODO: put the custom_views in an options hash
    def run(custom_views = [])
      parsed_options             = option_parser.results
      first.class.parsed_options = parsed_options

      custom_views.each { |v| first.formatter.views_directories << v }

      redirect_output_to_file(parsed_options[:output]) if parsed_options[:output]

      each         { |c| c.before_scan }
      each         { |c| c.run }
      reverse.each { |c| c.after_scan }
    end
  end
end
