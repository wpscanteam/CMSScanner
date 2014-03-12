module CMSScanner
  module Controller
    # Core Controller
    class Core < Base
      def self.cli_options
        [
          OptParseValidator::OptBoolean.new(%w{-v --verbose}),
          OptParseValidator::OptURL.new(['-u', '--url URL'], required: true),
          OptParseValidator::OptString.new(['-o', '--output FILE', 'Output to FILE']) # TODO: modify the OptFilePath for writing permissions
        ]
      end

      def before_scan
        # puts 'Core Before'
        @url = target.url
        puts render('start')

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
