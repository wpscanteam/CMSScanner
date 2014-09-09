require_relative 'interesting_files/robots_txt'

module CMSScanner
  module Finders
    # Interesting Files Finder
    class InterestingFiles
      include IndependantFinder

      # @param [ CMSScanner::Target ] target
      def initialize(target)
        finders << InterestingFile::RobotsTxt.new(target)
      end
    end
  end
end
