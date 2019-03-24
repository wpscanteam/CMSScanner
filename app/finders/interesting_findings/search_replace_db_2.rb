# frozen_string_literal: true

module CMSScanner
  module Finders
    module InterestingFindings
      # SearchReplaceDB2 finder
      class SearchReplaceDB2 < Finder
        # @return [ String ] The path to the searchreplacedb2 PHP file
        def path
          @path ||= 'searchreplacedb2.php'
        end

        # @return [ InterestingFinding ]
        def aggressive(_opts = {})
          return unless target.head_and_get(path).body =~ /by interconnect/i

          NS::Model::InterestingFinding.new(target.url(path),
                                            confidence: 100,
                                            found_by: found_by,
                                            references: references)
        end

        def references
          { url: 'https://interconnectit.com/products/search-and-replace-for-wordpress-databases/' }
        end
      end
    end
  end
end
