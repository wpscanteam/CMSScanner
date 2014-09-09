module CMSScanner
  module Finders
    module InterestingFile
      # SearchReplaceDB2 finder
      class SearchReplaceDB2 < Finder
        # @return [ String ] The url to the searchreplacedb2 PHP file
        def url
          target.uri.join('searchreplacedb2.php').to_s
        end

        # @return [ InterestingFile ]
        def aggressive(_opts = {})
          res = Typhoeus.get(url)

          return unless res && res.code == 200 && res.body =~ /by interconnect/i

          CMSScanner::InterestingFile.new(url, confidence: 100,
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
