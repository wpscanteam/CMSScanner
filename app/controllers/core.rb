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
        output('banner')

        setup_cache

        fail "The url supplied '#{target.url}' seems to be down" unless target.online?

        fail AccessForbiddenError if target.access_forbidden?
        fail HTTPAuthRequiredError if target.http_auth?
        fail ProxyAuthRequiredError if target.proxy_auth?

        # TODO: ask if the redirection should be followed
        # if user_interaction? is allowed (if followed, the Cache#storage_path should be updated)
        redirection = target.redirection
        fail "The url supplied redirects to #{redirection}" if redirection
      end

      def run
        @start_time   = Time.now
        @start_memory = memory_usage

        output('started', url: target.url)
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
