require 'ruby-progressbar/outputs/null'

class ProgressBar
  module Outputs
    # Adds the feature to log message sent to #log
    # So they can be retrieved at some point, like after a password attack with a JSON output
    # which won't display the progressbar but still call #log for errors etc
    # See https://github.com/jfelchner/ruby-progressbar/issues/144
    class Null < Output
      # @retutn [ Array<String> ]
      def logs
        @logs ||= []
      end

      # Override of parent method
      # @return [ Array<String> ] return the logs when no string provided
      def log(string = nil)
        return logs if string.nil?

        logs << string
      end
    end
  end
end
