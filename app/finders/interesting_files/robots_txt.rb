module CMSScanner
  module Finder
    module InterestingFiles
      # Robots.txt finder
      class RobotsTxt < Base
        # @return [ String ] The url of the robots.txt file
        def url
          target.uri.join('robots.txt').to_s
        end

        def aggressive(_opts = {})
          res = Typhoeus.get(url)
          # TODO: more accurate check
          { result: url, confidence: 100 } if res.code == 200
        end
      end
    end
  end
end
