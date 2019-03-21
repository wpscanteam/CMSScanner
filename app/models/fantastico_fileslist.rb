# frozen_string_literal: true

module CMSScanner
  module Model
    # FantasticoFileslist
    class FantasticoFileslist < InterestingFinding
      # @return [ Array<String> ] The interesting files/dirs detected
      def interesting_entries
        results = []

        entries.each do |entry|
          next unless entry =~ /(?:admin|\.log|\.sql|\.db)/i

          results << entry
        end
        results
      end

      def references
        { url: ['http://www.acunetix.com/vulnerabilities/fantastico-fileslist/'] }
      end
    end
  end
end
