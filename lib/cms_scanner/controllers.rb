# frozen_string_literal: true

module CMSScanner
  # Controllers Container
  class Controllers < Array
    attr_reader :option_parser, :running

    # @param [ OptParsevalidator::OptParser ] options_parser
    def initialize(option_parser = OptParseValidator::OptParser.new(nil, 40))
      @option_parser = option_parser

      register_config_files

      option_parser.config_files.result_key = 'cli_options'
    end

    # Adds the potential option file paths to the option_parser
    def register_config_files
      [Dir.home, Dir.pwd].each do |dir|
        option_parser.config_files.class.supported_extensions.each do |ext|
          option_parser.config_files << Pathname.new(dir).join(".#{NS.app_name}", "scan.#{ext}").to_s
        end
      end
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
      NS::ParsedCli.options     = option_parser.results
      first.class.option_parser = option_parser # To be able to output the help when -h/--hh

      redirect_output_to_file(NS::ParsedCli.output) if NS::ParsedCli.output

      Timeout.timeout(NS::ParsedCli.max_scan_duration, NS::Error::MaxScanDurationReached) do
        each(&:before_scan)

        @running = true

        each(&:run)
      end
    ensure
      # The rescue is there to prevent unfinished requests to raise an error, which would prevent
      # the reverse_each to run
      # rubocop:disable Style/RescueModifier
      NS::Browser.instance.hydra.abort rescue nil
      # rubocop:enable Style/RescueModifier

      # Reverse is used here as the app/controllers/core#after_scan finishes the output
      # and must be the last one to be executed. It also guarantee that stats will be output
      # even when an error occurs, which could help in debugging.
      # However, the #after_scan methods are only executed if the scan was running, and won't be
      # called when there is a CLI error, or just -h/--hh/--version for example
      reverse_each(&:after_scan) if running
    end
  end
end
