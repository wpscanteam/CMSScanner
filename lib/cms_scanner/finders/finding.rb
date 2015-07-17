require 'cms_scanner/references'

module CMSScanner
  module Finders
    # Finding
    module Finding
      include References

      FINDING_OPTS = [:confidence, :confirmed_by, :references, :found_by, :interesting_entries]

      attr_accessor(*FINDING_OPTS)

      # @return [ Hash ]
      def references
        @references ||= {}
      end

      # @return [ Array ]
      def confirmed_by
        @confirmed_by ||= []
      end

      # Should be overriden in child classes
      # @return [ Array ]
      def interesting_entries
        @interesting_entries ||= []
      end

      # @return [ Integer ]
      def confidence
        @confidence ||= 0
      end

      # @param [ Integer ] value
      def confidence=(value)
        @confidence = value >= 100 ? 100 : value
      end

      # @param [ Hash ] opts
      # TODO: Maybe use instance_variable_set ?
      def parse_finding_options(opts = {})
        FINDING_OPTS.each { |opt| send("#{opt}=", opts[opt]) if opts.key?(opt) }
      end

      def eql?(other)
        self == other && confidence == other.confidence && found_by == other.found_by
      end

      def <=>(other)
        to_s.downcase <=> other.to_s.downcase
      end
    end
  end
end
