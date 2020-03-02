# frozen_string_literal: true

module CMSScanner
  module Model
    # SearchReplaceDB2
    class SearchReplaceDB2 < InterestingFinding
      def references
        @references ||= { url: 'https://interconnectit.com/products/search-and-replace-for-wordpress-databases/' }
      end
    end
  end
end
