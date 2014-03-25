module CMSScanner
  module Controller
    # Core Controller
    class Core < Base
      def cli_options
        [
          OptBoolean.new(%w(-v --verbose)),
          OptURL.new(['-u', '--url URL'], required: true),
          OptString.new(['-o', '--output FILE', 'Output to FILE']), # TODO: modify the OptFilePath for writing permissions
          OptString.new(['-f', '--format FORMAT']) # Should be OptChoice
        ]
      end

      def before_scan
        # TODO: basic checks (target.online? etc)
      end

      def run
        @start_time   = Time.now
        @start_memory = memory_usage

        output('started', url: target.url)
        sleep(2) # Simulate a scan
        # fail 'dummy error'
      end

      def after_scan
        @stop_time   = Time.now
        @elapsed     = @stop_time - @start_time
        @used_memory = memory_usage - @start_memory

        output('finished')
      end
    end
  end
end
