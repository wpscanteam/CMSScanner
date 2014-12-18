module CMSScanner
  module Finders
    # Findings container
    class Findings < Array
      # Override to include the confirmed_by logic
      #
      # @param [ Finding ] finding
      def <<(finding)
        each do |found|
          next unless found == finding

          found.confirmed_by << finding

          confidence = (found.confidence + finding.confidence) / 1.5
          confidence = 100 if confidence > 100 || finding.confidence == 100

          found.confidence = confidence.floor unless found.confidence == 100

          return self
        end

        super(finding)
      end
    end
  end
end
