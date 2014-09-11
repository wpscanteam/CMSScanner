module CMSScanner
  # FantasticoFileslist
  class FantasticoFileslist < InterestingFile
    # @return [ Array<String> ] The interesting files/dirs detected
    def interesting_entries
      results = []

      entries.each do |entry|
        next unless entry =~ /(?:admin|\.log|\.sql|\.db)/i

        results << entry
      end
      results
    end
  end
end
