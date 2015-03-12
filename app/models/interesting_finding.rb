module CMSScanner
  # Interesting Finding
  class InterestingFinding
    include NS::Finders::Finding

    attr_reader :url
    attr_writer :to_s

    # @param [ String ] url
    # @param [ Hash ] opts
    #   :to_s (override the to_s method)
    #   See Finders::Finding for other available options
    def initialize(url, opts = {})
      @url  = url
      @to_s = opts[:to_s]

      parse_finding_options(opts)
    end

    # @return [ Array<String> ]
    def entries
      res = NS::Browser.get(url)

      return [] unless res && res.headers['Content-Type'] =~ /\Atext\/plain;/i

      res.body.split("\n").reject { |s| s.strip.empty? }
    end

    def to_s
      @to_s || url
    end

    def ==(other)
      return false unless self.class == other.class
      url == other.url
    end
  end
end
