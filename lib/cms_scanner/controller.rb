module CMSScanner
  module Controller
    # Base Controller
    class Base
      def initialize
      end

      def target
        @@target ||= Target.new(parsed_options[:url])
      end

      def verbose?
        parsed_options[:verbose]
      end

      # @param [ Hash ] options
      def self.parsed_options=(options)
        @@parsed_options = options
      end

      def parsed_options
        @@parsed_options
      end

      def formatter
        @@formatter ||= Formatter::Cli.new
      end

      def before_scan; end

      def run; end

      def after_scan; end

      # @return [ Array<OptParseValidator::OptBase> ]
      def self.cli_options; end
    end
  end
end
