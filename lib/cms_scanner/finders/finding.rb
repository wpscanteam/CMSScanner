module CMSScanner
  module Finders
    # Finding
    module Finding
      attr_accessor :confidence, :confirmed_by, :references, :found_from

      def references
        @references ||= []
      end

      def confirmed_by
        @confirmed_by ||= []
      end

      def ==(_other)
        # return false unless self.class == other.class

        false
      end
    end
  end
end
