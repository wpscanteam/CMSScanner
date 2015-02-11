module CMSScanner
  # Version
  class Version
    include NS::Finders::Finding

    attr_reader :number

    def initialize(number, opts = {})
      @number = number.to_s
      parse_finding_options(opts)
    end

    def ==(other)
      number == other.number
    end
  end
end
