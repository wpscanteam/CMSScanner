module CMSScanner
  module Finders
    module InterestingFile
      # Robots.txt finder
      class RobotsTxt < Finder
        # @return [ String ] The url of the robots.txt file
        def url
          target.uri.join('robots.txt').to_s
        end

        def aggressive(_opts = {})
          res = Typhoeus.get(url)

          # TODO: more accurate check
          return unless res.code == 200

          CMSScanner::InterestingFile.new(url, confidence: 100, found_by: found_by)
        end
      end
    end
  end
end
