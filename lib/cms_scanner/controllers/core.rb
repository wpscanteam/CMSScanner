module CMSScanner
  module Controller
    # Core Controller
    class Core < Base
      def cli_options
        [
          OptParseValidator::OptBoolean.new(%w{-v --verbose}),
          OptParseValidator::OptURL.new(['-u', '--url URL'], required: true),
          OptParseValidator::OptString.new(['-o', '--output FILE', 'Output to FILE']), # TODO: modify the OptFilePath for writing permissions
          OptParseValidator::OptString.new(['-f', '--format FORMAT']) # Should be OptChoice
        ]
      end

      def before_scan
        output('start', url: target.url)

        target.url = 'http://new-url.com/'
      end

      def run
        # puts 'Core Running'
      end

      def after_scan
        # puts 'Core After'
      end
    end
  end
end
