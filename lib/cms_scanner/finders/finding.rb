module CMSScanner
  module Finders
    # Finding
    module Finding
      FINDING_OPTS = [:confidence, :confirmed_by, :references, :found_by]

      attr_accessor(*FINDING_OPTS)

      # @return [ Array ]
      def references
        @references ||= []
      end

      # @return [ Array ]
      def confirmed_by
        @confirmed_by ||= []
      end

      # @param [ Hash ] opts
      # TODO: Maybe use instance_variable_set ?
      def parse_finding_options(opts = {})
        FINDING_OPTS.each { |opt| send("#{opt}=", opts[opt]) if opts.key?(opt) }
      end
    end
  end
end
