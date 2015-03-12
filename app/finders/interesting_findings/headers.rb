module CMSScanner
  module Finders
    module InterestingFindings
      # Interesting Headers finder
      class Headers < Finder
        # @return [ InterestingFinding ]
        def passive(_opts = {})
          r = NS::Headers.new(target.url, confidence: 100, found_by: found_by)

          r.interesting_entries.empty? ? nil : r
        end
      end
    end
  end
end
