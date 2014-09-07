module CMSScanner
  module Finders
    # Finder
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
