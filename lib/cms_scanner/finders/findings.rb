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

      # TODO: check for the #+ to see if it uses #<<
    end
  end
end
