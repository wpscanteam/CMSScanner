module CMSScanner
  module Controller
    # Core Controller
    class Core < Base
      def cli_options
        [
          OptBoolean.new(%w(-v --verbose)),
          OptURL.new(['-u', '--url URL'], required: true),
          # TODO: modify the OptFilePath for writing permissions
          OptString.new(['-o', '--output FILE', 'Output to FILE']),
          OptString.new(['-f', '--format FORMAT']), # Should be OptChoice
          OptString.new(['--basic-auth login:password']) # TODO: Create an OptCredentials
        ]
      end

      def before_scan
        fail "The url supplied '#{target.url}' seems to be down" unless target.online?

        if target.basic_auth? && !parsed_options[:basic_auth]
          fail 'Basic authentication is required, please provide it with --basic-auth'
        end

        # TODO: ask if the redirection should be followed
        # if user_interaction? is allowed
        if (redirection = target.redirection)
          fail "The url supplied redirects to #{redirection}"
        end
      end

      def run
        @start_time   = Time.now
        @start_memory = memory_usage

        output('started', url: target.url)
        # sleep(2) # Simulate a scan
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
