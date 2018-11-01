require_relative 'core/cli_options'

module CMSScanner
  module Controller
    # Core Controller
    class Core < Base
      def setup_cache
        return unless parsed_options[:cache_dir]

        storage_path = File.join(parsed_options[:cache_dir], Digest::MD5.hexdigest(target.url))

        Typhoeus::Config.cache = Cache::Typhoeus.new(storage_path)
        Typhoeus::Config.cache.clean if parsed_options[:clear_cache]
      end

      def before_scan
        maybe_output_banner_help_and_version

        setup_cache
        check_target_availability
      end

      def maybe_output_banner_help_and_version
        output('banner') if parsed_options[:banner]
        output('help', help: option_parser.simple_help, simple: true) if parsed_options[:help]
        output('help', help: option_parser.full_help, simple: false) if parsed_options[:hh]
        output('version') if parsed_options[:version]

        exit(NS::ExitCode::OK) if parsed_options[:help] || parsed_options[:hh] || parsed_options[:version]
      end

      # Checks that the target is accessible, raises related errors otherwise
      #
      # @return [ Void ]
      def check_target_availability
        res = NS::Browser.get(target.url)

        case res.code
        when 0
          raise TargetDownError, res
        when 401
          raise HTTPAuthRequiredError
        when 403
          raise AccessForbiddenError
        when 407
          raise ProxyAuthRequiredError
        end

        # Checks for redirects
        # An out of scope redirect will raise an HTTPRedirectError
        effective_url = target.homepage_res.effective_url

        return if target.in_scope?(effective_url)

        raise HTTPRedirectError, effective_url unless parsed_options[:ignore_main_redirect]

        target.homepage_res = res
      end

      def run
        @start_time   = Time.now
        @start_memory = memory_usage

        output('started', url: target.url, effective_url: target.homepage_url)
      end

      def after_scan
        @stop_time   = Time.now
        @elapsed     = @stop_time - @start_time
        @used_memory = memory_usage - @start_memory

        output('finished',
               requests_done: NS.total_requests,
               data_sent: NS.total_data_sent,
               data_received: NS.total_data_received)
      end
    end
  end
end
