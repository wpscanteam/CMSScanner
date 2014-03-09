module CMSScanner
  module Controller
    # Core Controller
    class Core < Base
      def self.cli_options
        [
          OptParseValidator::OptBoolean.new(%w[-v --verbose]),
          OptParseValidator::OptString.new(['-u', '--url URL'], required: true)
        ]
      end

      def before_scan
        puts "Core Before #{target.url}"
        target.url = 'http://new-url.com/'
      end

      def run
        puts 'Core Running'
      end

      def after_scan
        puts 'Core After'
      end
    end
  end
end
