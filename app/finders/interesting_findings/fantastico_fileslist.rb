module CMSScanner
  module Finders
    module InterestingFindings
      # FantasticoFileslist finder
      class FantasticoFileslist < Finder
        # @return [ String ] The url of the fantastico_fileslist.txt file
        def url
          target.url('fantastico_fileslist.txt')
        end

        # @return [ InterestingFinding ]
        def aggressive(_opts = {})
          res = NS::Browser.get(url)

          return unless res&.code == 200 && !res.body.empty?
          return unless res.headers && res.headers['Content-Type'] =~ %r{\Atext/plain}

          NS::Model::FantasticoFileslist.new(url, confidence: 70, found_by: found_by)
        end
      end
    end
  end
end
