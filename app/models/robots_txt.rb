module CMSScanner
  # Robots.txt
  class RobotsTxt < InterestingFile
    # @todo Better detection, currently everythinh not empty or / is returned
    #
    # @return [ Array<String> ] The interesting Allow/Disallow rules detected
    def interesting_entries
      results = []

      entries.each do |entry|
        next unless entry =~ /\A(?:dis)?allow:\s*(.+)\z/i
        match = Regexp.last_match(1)
        next if match == '/'

        results << match
      end
      results
    end
  end
end
