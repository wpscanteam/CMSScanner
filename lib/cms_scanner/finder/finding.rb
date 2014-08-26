module CMSScanner
  module Finder
    # Container for a result found with a finder
    class Finding
      attr_reader :result, :method, :confidence

      # @param [ Mixed ] result
      # @param [ String ] method The method used to detect/find the result
      # @param [ Integer ] confidence The confidence of the finding in percent
      def initialize(result, method = nil, confidence = nil)
        @result     = result
        @confidence = confidence
        @method     = method
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
