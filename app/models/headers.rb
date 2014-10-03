module CMSScanner
  # Not really an interesting file, but will use this class for convenience
  class Headers < InterestingFile
    # @return [ Hash ] The headers
    def entries
      res = NS::Browser.get(url)
      return [] unless res && res.headers
      res.headers
    end

    # @return [ Array<String> ] The interesting headers detected
    def interesting_entries
      results = []

      entries.each do |header, value|
        next if known_headers.include?(header.downcase)

        results << "#{header}: #{value}"
      end
      results
    end

    # @return [ Array<String> ] Downcased known headers
    def known_headers
      %w(
        age accept-ranges cache-control content-type content-length connection date etag expires
        location last-modified pragma set-cookie strict-transport-security transfer-encoding vary
        x-cache x-content-security-policy x-content-type-options x-frame-options x-language
        x-permitted-cross-domain-policies x-pingback x-varnish x-webkit-csp x-xss-protection
      )
    end

    def eql?(other)
      super(other) && interesting_entries == other.interesting_entries
    end
  end
end
