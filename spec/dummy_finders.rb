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

  module Finders
    # Dummy Test Finder
    class DummyFinder < Finder
      def passive(_opts = {})
        DummyFinding.new('test', found_by: found_by)
      end

      def aggressive(_opts = {})
        DummyFinding.new('test', confidence: 100, found_by: 'override')
      end
    end

    # No aggressive result finder
    class NoAggressiveResult < Finder
      def passive(_opts = {})
        DummyFinding.new('spotted', confidence: 10, found_by: found_by)
      end
    end
  end
end
