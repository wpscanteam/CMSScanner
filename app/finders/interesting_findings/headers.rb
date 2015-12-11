module CMSScanner
  module Finders
    module InterestingFindings
      # Interesting Headers finder
      class Headers < Finder
        # @return [ InterestingFinding ]
        def passive(_opts = {})
          # TODO: change target.url by target.homepage_url once https://github.com/bblimke/webmock/issues/552
          # has been properly remediated
          r = NS::Headers.new(target.url, confidence: 100, found_by: found_by)

          r.interesting_entries.empty? ? nil : r
        end
      end
    end
  end
end
