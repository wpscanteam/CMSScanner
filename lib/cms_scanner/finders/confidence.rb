module CMSScanner
  module Finders
    # Confidence
    class Confidence < Numeric
      attr_reader :value

      def initialize(value)
        @value = value
      end

      # @param [ Integer, Confidence ] other
      #
      # TODO: rework the formula which is weak when the value to add is < the current confidence
      # e.g: 90 + 50 + 30 => 82
      #
      # @return [ Confidence ] A new Confidence
      def +(other)
        return Confidence.new(100) if @value == 100

        to_add    = other_value(other)
        new_value = (@value + to_add) / 1.5
        new_value = 100 if new_value > 100 || to_add == 100

        Confidence.new(new_value.floor)
      end

      #
      ## Convenient Methods
      #
      #:nocov:
      def to_s
        @value.to_s
      end

      def to_json
        @value.to_json
      end

      # @param [ Integer, Confidence ] other
      def other_value(other)
        other.is_a?(Confidence) ? other.value : other
      end

      # @param [ Integer, Confidence ] other
      def ==(other)
        @value == other_value(other)
      end

      # @param [ Integer, Confidence ] other
      def eql?(other)
        @value.eql?(other_value(other))
      end

      # @param [ Integer, Confidence ] other
      def <(other)
        @value < other_value(other)
      end

      # @param [ Integer, Confidence ] other
      def <=(other)
        @value <= other_value(other)
      end

      # @param [ Integer, Confidence ] other
      def >(other)
        @value > other_value(other)
      end

      # @param [ Integer, Confidence ] other
      def >=(other)
        @value >= other_value(other)
      end

      # @param [ Integer, Confidence ] other
      def <=>(other)
        @value <=> other_value(other)
      end
      #:nocov:
    end
  end
end
