module CMSScanner
  module Finders
    module InterestingFile
      # FantasticoFileslist finder
      class FantasticoFileslist < Finder
        # @return [ String ] The url of the fantastico_fileslist.txt file
        def url
          target.uri.join('fantastico_fileslist.txt').to_s
        end

        # @return [ InterestingFile ]
        def aggressive(_opts = {})
          res = NS::Browser.get(url)

          return unless res && res.code == 200 && res.body.length > 0
          return unless res.headers && res.headers['Content-Type'] =~ /\Atext\/plain/

          NS::FantasticoFileslist.new(url, confidence: 100,
                                           found_by: found_by,
                                           references: references)
        end

        def references
          %w(http://www.acunetix.com/vulnerabilities/fantastico-fileslist/)
        end
      end
    end
  end
end
