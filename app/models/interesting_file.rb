module CMSScanner
  # Interesting File
  class InterestingFile
    include Finders::Finding

    attr_reader :url

    def initialize(url, opts = {})
      @url = url
      parse_finding_options(opts)
    end

    def ==(other)
      url == other.url
    end

    def eql?(other)
      url == other.url && confidence == other.confidence && found_by == other.found_by
    end
  end
end
