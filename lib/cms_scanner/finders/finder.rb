module CMSScanner
  module Finders
    # Finder
    class Finder
      # Constants for common found_by
      DIRECT_ACCESS = 'Direct Access (aggressive detection)'

      attr_accessor :target

      def initialize(target)
        @target = target
      end

      # @param [ Hash ] _opts
      def passive(_opts = {})
      end

      # @param [ Hash ] _opts
      def aggressive(_opts = {})
      end

      def found_by
        "#{self.class.to_s.demodulize} (#{caller_locations(1, 1)[0].label} detection)"
      end
    end
  end
end
