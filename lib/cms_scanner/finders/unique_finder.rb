# frozen_string_literal: true

module CMSScanner
  module Finders
    # Unique Finder
    module UniqueFinder
      def self.included(klass)
        klass.class_eval do
          include IndependentFinder

          # @return [ Array ]
          def finders
            @finders ||= NS::Finders::UniqueFinders.new
          end
        end
      end
    end
  end
end
