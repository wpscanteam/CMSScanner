module CMSScanner
  module Finders
    module InterestingFile
      # SearchReplaceDB2 finder
      class SearchReplaceDB2 < Finder
        # @return [ String ] The url to the searchreplacedb2 PHP file
        def url
          target.url('searchreplacedb2.php')
        end

        # @return [ InterestingFile ]
        def aggressive(_opts = {})
          res = NS::Browser.get(url)

          return unless res && res.code == 200 && res.body =~ /by interconnect/i

          NS::InterestingFile.new(url, confidence: 100,
                                       found_by: found_by,
                                       references: references)
        end

        def references
          %w(https://interconnectit.com/products/search-and-replace-for-wordpress-databases/)
        end
      end
    end
  end
end
