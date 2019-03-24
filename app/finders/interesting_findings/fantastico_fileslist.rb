# frozen_string_literal: true

module CMSScanner
  module Finders
    module InterestingFindings
      # FantasticoFileslist finder
      class FantasticoFileslist < Finder
        # @return [ String ] The path of the fantastico_fileslist.txt file
        def path
          @path ||= 'fantastico_fileslist.txt'
        end

        # @return [ InterestingFinding ]
        def aggressive(_opts = {})
          res = target.head_and_get(path)

          return if res.body.strip.empty?
          return unless res.headers && res.headers['Content-Type'] =~ %r{\Atext/plain}

          NS::Model::FantasticoFileslist.new(target.url(path), confidence: 70, found_by: found_by)
        end
      end
    end
  end
end
