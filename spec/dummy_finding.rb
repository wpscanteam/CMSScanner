module CMSScanner
  # Dummy Finding
  class DummyFinding
    include Finders::Finding

    attr_reader :r

    def initialize(r, opts = {})
      @r = r
      parse_finding_options(opts)
    end

    def ==(other)
      r == other.r
    end

    def eql?(other)
      r == other.r && confidence == other.confidence && found_by == other.found_by
    end
  end
end
