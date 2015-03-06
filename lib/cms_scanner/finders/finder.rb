require 'cms_scanner/finders/finder/smart_url_checker'
require 'cms_scanner/finders/finder/enumerator'
require 'cms_scanner/finders/finder/fingerprinter'

module CMSScanner
  module Finders
    # Finder
    class Finder
      # Constants for common found_by
      DIRECT_ACCESS = 'Direct Access (Aggressive Detection)'

      attr_accessor :target

      def initialize(target)
        @target = target
      end

      # @return [ String ] The titleized name of the finder
      def titleize
        self.class.to_s.demodulize.underscore.titleize
      end

      # @param [ Hash ] _opts
      def passive(_opts = {})
      end

      # @param [ Hash ] _opts
      def aggressive(_opts = {})
      end

      # @param [ Hash ] opts See https://github.com/jfelchner/ruby-progressbar/wiki/Options
      #
      # @return [ ProgressBar::Base ]
      def progress_bar(opts = {})
        ProgressBar.create({ format: '%t %a <%B> (%c / %C) %P%% %e' }.merge(opts))
      end

      # @return [ Browser ]
      def browser
        @browser ||= NS::Browser.instance
      end

      # @return [ Typhoeus::Hydra ]
      def hydra
        @hydra ||= browser.hydra
      end

      def found_by
        caller_locations.each do |call|
          label = call.label

          next unless label == 'aggressive' || label == 'passive'

          return "#{titleize} (#{label.capitalize} Detection)"
        end
      end
    end
  end
end
