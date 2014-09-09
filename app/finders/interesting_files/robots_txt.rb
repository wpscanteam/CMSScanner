module CMSScanner
  module Finders
    module InterestingFile
      # Robots.txt finder
      class RobotsTxt < Finder
        # @return [ String ] The url of the robots.txt file
        def url
          target.uri.join('robots.txt').to_s
        end

        # @return [ InterestingFile ]
        def aggressive(_opts = {})
          res = Typhoeus.get(url)

          return unless res && res.code == 200
          return unless res.body =~ /(?:user-agent|(?:dis)?allow):/i

          CMSScanner::InterestingFile.new(url, confidence: 100, found_by: found_by)
        end
      end
    end
  end
end
