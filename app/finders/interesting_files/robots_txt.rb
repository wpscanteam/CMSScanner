module CMSScanner
  module Finders
    module InterestingFile
      # Robots.txt finder
      class RobotsTxt < Finders::Finder
        # @return [ String ] The url of the robots.txt file
        def url
          target.uri.join('robots.txt').to_s
        end

        def aggressive(_opts = {})
          res = Typhoeus.get(url)

          # TODO: more accurate check
          return unless res.code == 200

          r = InterestingFile.new(url)
          r.confidence = 100
          r
        end
      end
    end
  end
end

module CMSScanner
  # Interesting File
  class InterestingFile
    include Finders::Finding

    attr_reader :url

    def initialize(url)
      @url = url
    end
  end
end
