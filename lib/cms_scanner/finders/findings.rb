module CMSScanner
  module Finders
    # Findings container
    class Findings < Array
      # Override to include the confirmed_by logic
      def <<(other)
        each do |found|
          next unless found == other

          found.confirmed_by << other
          # TODO: Increase confidence (e.g: (found + other) / 1.5 ?)
          return self
        end

        super(other)
      end

      # Append the elements of other into self AND returns self
      # This is not the default behaviour of Array#+ but it's intended
      def +(other)
        other.each { |f| self << f }
      end
    end
  end
end
