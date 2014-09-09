require_relative 'interesting_files/robots_txt'
require_relative 'interesting_files/fantastico_fileslist'

module CMSScanner
  module Finders
    # Interesting Files Finder
    class InterestingFiles
      include IndependantFinder

      # @param [ CMSScanner::Target ] target
      def initialize(target)
        finders << InterestingFile::RobotsTxt.new(target) <<
                   InterestingFile::FantasticoFileslist.new(target)
      end
    end
  end
end
