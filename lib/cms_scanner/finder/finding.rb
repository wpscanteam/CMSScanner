module CMSScanner
  module Finder
    # Container for a result found with a finder
    class Finding
      attr_reader :result

      ATTRS = [:method, :confidence, :references]

      attr_accessor(*ATTRS)

      # @param [ Mixed ] result
      # @param [ Hash ] opts
      # @options opts [ String ] :method The method used to detect/find the result
      # @options opts [ Integer ] :confidence The confidence of the finding in percent
      # @options opts [ Array<String> ] :references Array of URLs for details about the finding
      def initialize(result, opts = {})
        @result = result

        ATTRS.each { |sym| send("#{sym}=", opts[sym]) if opts.key?(sym) }
      end

      def references=(refs)
        @references = [*refs]
      end

      def references
        @references ||= []
      end

      def to_s
        result.to_s
      end

      def eql?(other)
        result == other.result &&
        method == other.method &&
        confidence == other.confidence
      end
    end
  end
end
