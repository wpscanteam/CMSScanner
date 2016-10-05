module CMSScanner
  module Finders
    # Same Type Finder
    module SameTypeFinder
      def self.included(klass)
        klass.class_eval do
          include IndependentFinder

          # @return [ Array ]
          def finders
            @finders ||= NS::Finders::SameTypeFinders.new
          end
          # rubocop:enable all
        end
      end
    end
  end
end
