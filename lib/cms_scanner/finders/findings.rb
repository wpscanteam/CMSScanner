module CMSScanner
  module Finders
    # Findings container
    class Findings < Array
      # Override to include the confirmed_by logic
      def <<(_other)
        # Draft
        each do |found|
          if found == other
            found.confirmed_by << other
            # Increase confidence (e.g: (self + other) / 1.5 ?)
          else
            super(other)
          end
        end
      end

      # TODO: check for the #+ to see if it uses #<<
    end
  end
end
