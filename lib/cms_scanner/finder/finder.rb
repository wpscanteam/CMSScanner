module CMSScanner
  module Finder
    # Base Finder
    class Finder
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
    end
  end
end
