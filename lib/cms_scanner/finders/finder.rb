require 'cms_scanner/mocked_progress_bar'
require 'cms_scanner/finders/finder/smart_url_checker'
require 'cms_scanner/finders/finder/enumerator'
require 'cms_scanner/finders/finder/fingerprinter'

module CMSScanner
  module Finders
    # Finder
    class Finder
      # Constants for common found_by
      DIRECT_ACCESS = 'Direct Access (Aggressive Detection)'.freeze

      attr_accessor :target, :progress_bar

      def initialize(target)
        @target = target
      end

      # @return [ String ] The titleized name of the finder
      def titleize
        self.class.to_s.demodulize.underscore.titleize
      end

      # @param [ Hash ] _opts
      def passive(_opts = {}); end

      # @param [ Hash ] _opts
      def aggressive(_opts = {}); end

      # @param [ Hash ] opts See https://github.com/jfelchner/ruby-progressbar/wiki/Options
      # @option opts [ Boolean ] :show_progression
      #
      # @return [ ProgressBar::Base, CMSScanner::MockedProgressBar ]
      def create_progress_bar(opts = {})
        klass = opts[:show_progression] ? ProgressBar : MockedProgressBar

        @progress_bar = klass.create({ format: '%t %a <%B> (%c / %C) %P%% %e' }.merge(opts))
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
        nil
      end
    end
  end
end
