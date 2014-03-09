module CMSScanner
  module Controller
    # Base Controller
    class Base
      def initialize
      end

      # @return [ Target ]
      def target
        @@target ||= Target.new(parsed_options[:url])
      end

      # @return [ Boolean ]
      def verbose?
        parsed_options[:verbose]
      end

      # @param [ Hash ] options
      def self.parsed_options=(options)
        @@parsed_options = options
      end

      # @return [ Hash ]
      def parsed_options
        @@parsed_options
      end

      # @return [ Formatter ]
      def formatter
        @@formatter ||= Formatter.load(parsed_options[:format])
      end

      def before_scan; end

      def run; end

      def after_scan; end

      # @return [ Array<OptParseValidator::OptBase> ]
      def self.cli_options; end
    end
  end
end
