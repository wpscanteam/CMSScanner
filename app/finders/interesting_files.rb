require_relative 'interesting_files/headers'
require_relative 'interesting_files/robots_txt'
require_relative 'interesting_files/fantastico_fileslist'
require_relative 'interesting_files/search_replace_db_2'
require_relative 'interesting_files/xml_rpc'

module CMSScanner
  module Finders
    # Interesting Files Finder
    class InterestingFiles
      include IndependantFinder

      # @param [ CMSScanner::Target ] target
      def initialize(target)
        finders << InterestingFile::Headers.new(target) <<
                   InterestingFile::RobotsTxt.new(target) <<
                   InterestingFile::FantasticoFileslist.new(target) <<
                   InterestingFile::SearchReplaceDB2.new(target) <<
                   InterestingFile::XMLRPC.new(target)
      end
    end
  end
end
