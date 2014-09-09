require_relative 'interesting_files/robots_txt'
require_relative 'interesting_files/fantastico_fileslist'
require_relative 'interesting_files/search_replace_db_2'

module CMSScanner
  module Finders
    # Interesting Files Finder
    class InterestingFiles
      include IndependantFinder

      # @param [ CMSScanner::Target ] target
      def initialize(target)
        finders << InterestingFile::RobotsTxt.new(target) <<
                   InterestingFile::FantasticoFileslist.new(target) <<
                   InterestingFile::SearchReplaceDB2.new(target)
      end
    end
  end
end
