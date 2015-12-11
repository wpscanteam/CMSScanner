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

      def before_scan(output_banner = true)
        output('banner') if output_banner

        setup_cache

        check_target_availability
      end

      # Checks that the target is accessible, raises related errors otherwise
      #
      # @return [ Void ]
      def check_target_availability
        res = NS::Browser.get(target.url)

        case res.code
        when 0
          fail TargetDownError, res
        when 401
          fail HTTPAuthRequiredError
        when 403
          fail AccessForbiddenError
        when 407
          fail ProxyAuthRequiredError
        end

        # Checks for redirects
        # An out of scope redirect will raise an HTTPRedirectError
        effective_url = target.homepage_res.effective_url.to_s

        return if target.in_scope?(effective_url)

        fail HTTPRedirectError, effective_url unless parsed_options[:ignore_main_redirect]

        target.homepage_res = res
      end

      def run
        @start_time   = Time.now
        @start_memory = memory_usage

        output('started', url: target.url, effective_url: target.homepage_url)
      end

      def after_scan
        @stop_time     = Time.now
        @elapsed       = @stop_time - @start_time
        @used_memory   = memory_usage - @start_memory
        @requests_done = CMSScanner.total_requests

        output('finished')
      end
    end
  end
end
