require_relative 'interesting_files/robots_txt'

module CMSScanner
  module Finders
    # Interesting Files Finder
    class InterestingFiles
      include Finders::IndependantFinder

      # @param [ CMSScanner::Target ] target
      def initialize(target)
        finders << Finders::InterestingFile::RobotsTxt.new(target)
      end
    end
  end
end
