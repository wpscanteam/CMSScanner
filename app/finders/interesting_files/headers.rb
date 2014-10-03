module CMSScanner
  module Finders
    module InterestingFile
      # Interesting Headers finder
      class Headers < Finder
        # @return [ InterestingFile ]
        def passive(_opts = {})
          r = NS::Headers.new(target.url, confidence: 100, found_by: found_by)

          r.interesting_entries.empty? ? nil : r
        end
      end
    end
  end
end
