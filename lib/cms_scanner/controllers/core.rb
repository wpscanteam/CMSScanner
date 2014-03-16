module CMSScanner
  module Controller
    # Core Controller
    class Core < Base
      def cli_options
        [
          OptBoolean.new(%w(-v --verbose)),
          OptURL.new(['-u', '--url URL'], required: true),
          OptString.new(['-o', '--output FILE', 'Output to FILE']), # TODO: modify the OptFilePath for writing permissions
          OptString.new(['-f', '--format FORMAT']) # Should be OptChoice
        ]
      end

      def before_scan
        output('start', url: target.url)

        target.url = 'http://new-url.com/'
      end

      def run
        # puts 'Core Running'
        # fail 'dummy error'
      end

      def after_scan
        # puts 'Core After'
      end
    end
  end
end
