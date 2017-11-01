module CMSScanner
  module Finders
    module InterestingFindings
      # Robots.txt finder
      class RobotsTxt < Finder
        # @return [ String ] The url of the robots.txt file
        def url
          target.url('robots.txt')
        end

        # @return [ InterestingFinding ]
        def aggressive(_opts = {})
          res = NS::Browser.get(url)

          return unless res&.code == 200 && res.body =~ /(?:user-agent|(?:dis)?allow):/i

          NS::RobotsTxt.new(url, confidence: 100, found_by: found_by)
        end
      end
    end
  end
end
