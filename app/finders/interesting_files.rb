require_relative 'interesting_files/headers'
require_relative 'interesting_files/robots_txt'
require_relative 'interesting_files/fantastico_fileslist'
require_relative 'interesting_files/search_replace_db_2'
require_relative 'interesting_files/xml_rpc'

module CMSScanner
  module Finders
    # Interesting Files Finder
    class InterestingFiles
      include IndependentFinder

      # @param [ CMSScanner::Target ] target
      def initialize(target)
        %w(Headers RobotsTxt FantasticoFileslist SearchReplaceDB2 XMLRPC).each do |f|
          finders << NS.const_get("Finders::InterestingFile::#{f}").new(target)
        end
      end
    end
  end
end
