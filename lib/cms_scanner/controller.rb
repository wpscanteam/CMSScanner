module CMSScanner
  module Controller
    # Base Controller
    class Base
      def initialize
      end

      # @param [ CMSScanner::Target ] target
      def self.target=(target)
        @@target = target
      end

      def target
        @@target
      end

      # @param [ Boolean ] verbose
      def self.verbose=(verbose)
        @@verbose = verbose
      end

      def verbose
        @@verbose
      end

      # @param [ Hash ] options
      def self.parsed_options=(options)
        @@parsed_options = options
      end

      def parsed_options
        @@parsed_options
      end

      # For output formating (TODO)
      def self.formatter=(formatter)
        @@formatter = formatter
      end

      def formatter
        @@formatter
      end

      def before_scan; end

      def run; end

      def after_scan; end

      # @return [ Array<OptParseValidator::OptBase> ]
      def self.cli_options; end
    end
  end
end
