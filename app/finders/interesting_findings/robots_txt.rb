# frozen_string_literal: true

module CMSScanner
  module Finders
    module InterestingFindings
      # Robots.txt finder
      class RobotsTxt < Finder
        # @return [ String ] The path of the robots.txt file
        def path
          @path ||= 'robots.txt'
        end

        # @return [ InterestingFinding ]
        def aggressive(_opts = {})
          # res = NS::Browser.get(url)
          res = target.head_and_get(path)

          return unless res&.code == 200 && res.body =~ /(?:user-agent|(?:dis)?allow):/i

          NS::Model::RobotsTxt.new(target.url(path), confidence: 100, found_by: found_by)
        end
      end
    end
  end
end
