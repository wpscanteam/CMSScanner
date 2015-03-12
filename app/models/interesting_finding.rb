module CMSScanner
  # Interesting Finding
  class InterestingFinding
    include NS::Finders::Finding

    attr_reader :url

    def initialize(url, opts = {})
      @url = url
      parse_finding_options(opts)
    end

    # @return [ Array<String> ]
    def entries
      res = NS::Browser.get(url)

      return [] unless res && res.headers['Content-Type'] =~ /\Atext\/plain;/i

      res.body.split("\n").reject { |s| s.strip.empty? }
    end

    def to_s
      url
    end

    def ==(other)
      return false unless self.class == other.class
      url == other.url
    end
  end
end
