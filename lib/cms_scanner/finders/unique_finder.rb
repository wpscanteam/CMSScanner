module CMSScanner
  module Finders
    # Unique Finder
    module UniqueFinder
      include IndependentFinder

      # @return [ Array ]
      def finders
        @finders ||= NS::Finders::UniqueFinders.new
      end
    end
  end
end
