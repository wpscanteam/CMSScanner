module CMSScanner
  module Finders
    # Finding
    module Finding
      FINDING_OPTS = [:confidence, :confirmed_by, :references, :found_by, :interesting_entries]

      attr_accessor(*FINDING_OPTS)

      # @return [ Array ]
      def references
        @references ||= []
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

      # @param [ Hash ] opts
      # TODO: Maybe use instance_variable_set ?
      def parse_finding_options(opts = {})
        FINDING_OPTS.each { |opt| send("#{opt}=", opts[opt]) if opts.key?(opt) }
      end

      def eql?(other)
        self == other && confidence == other.confidence && found_by == other.found_by
      end
    end
  end
end
