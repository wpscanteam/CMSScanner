# frozen_string_literal: true

require_relative 'interesting_findings/headers'
require_relative 'interesting_findings/robots_txt'
require_relative 'interesting_findings/fantastico_fileslist'
require_relative 'interesting_findings/search_replace_db_2'
require_relative 'interesting_findings/xml_rpc'

module CMSScanner
  module Finders
    module InterestingFindings
      # Interesting Files Finder
      class Base
        include IndependentFinder

        # @param [ CMSScanner::Target ] target
        def initialize(target)
          %w[Headers RobotsTxt FantasticoFileslist SearchReplaceDB2 XMLRPC].each do |f|
            finders << NS::Finders::InterestingFindings.const_get(f).new(target)
          end
        end
      end
    end
  end
end
