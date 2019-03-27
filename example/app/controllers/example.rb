# frozen_string_literal: true

module CMSScan
  module Controller
    # Example Controller
    class Example < CMSScanner::Controller::Core
      # @return [ Array<OptParseValidator::Opt> ]
      def cli_options
        [
          OptString.new(['--dummy VALUE', 'Dummy CLI Option'])
        ]
      end

      def before_scan
        # Anything to do before ?
      end

      def run
        # Let's check and display whether or not the word 'scan' is present in the homepage of the target

        is_present = target.homepage_res.body =~ /scan/ ? true : false

        output('scan_word', is_present: is_present)
      end

      # Alternative way of doing it
      def run2
        @is_present = Browser.get(target.homepage_url).body =~ /scan/ ? true : false

        output('scan_word')
      end

      def after_scan
        # Anything after ?
      end
    end
  end
end
