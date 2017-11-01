module CMSScanner
  module Finders
    module InterestingFindings
      # SearchReplaceDB2 finder
      class SearchReplaceDB2 < Finder
        # @return [ String ] The url to the searchreplacedb2 PHP file
        def url
          target.url('searchreplacedb2.php')
        end

        # @return [ InterestingFinding ]
        def aggressive(_opts = {})
          res = NS::Browser.get(url)

          return unless res&.code == 200 && res.body =~ /by interconnect/i

          NS::InterestingFinding.new(url, confidence: 100,
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
