module CMSScanner
  module Controller
    # Custom Controller
    class Custom < Controller::Base
      def before_scan
        puts "Custom Before #{target.url}"
      end

      def run
        puts 'Custom Running'
      end

      def after_scan
        puts 'Custom After'
      end
    end
  end
end
