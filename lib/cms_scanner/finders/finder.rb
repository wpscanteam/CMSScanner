require 'cms_scanner/finders/finder/smart_url_checker'
require 'cms_scanner/finders/finder/enumerator'

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

      # @return [ String ] The titleize name of the finder
      def titleize
        self.class.to_s.demodulize.underscore.titleize
      end

      # @param [ Hash ] _opts
      def passive(_opts = {})
      end

      # @param [ Hash ] _opts
      def aggressive(_opts = {})
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
