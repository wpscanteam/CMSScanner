# frozen_string_literal: true

require_relative 'core/cli_options'

module CMSScanner
  module Controller
    # Core Controller
    class Core < Base
      def setup_cache
        return unless NS::ParsedCli.cache_dir

        storage_path = File.join(NS::ParsedCli.cache_dir, Digest::MD5.hexdigest(target.url))

        Typhoeus::Config.cache = Cache::Typhoeus.new(storage_path)
        Typhoeus::Config.cache.clean if NS::ParsedCli.clear_cache
      end

      def before_scan
        maybe_output_banner_help_and_version

        setup_cache
        check_target_availability
      end

      def maybe_output_banner_help_and_version
        output('banner') if NS::ParsedCli.banner
        output('help', help: option_parser.simple_help, simple: true) if NS::ParsedCli.help
        output('help', help: option_parser.full_help, simple: false) if NS::ParsedCli.hh
        output('version') if NS::ParsedCli.version

        exit(NS::ExitCode::OK) if NS::ParsedCli.help || NS::ParsedCli.hh || NS::ParsedCli.version
      end

      # Checks that the target is accessible, raises related errors otherwise
      #
      # @return [ Void ]
      def check_target_availability
        res = NS::Browser.get(target.url)

        case res.code
        when 0
          raise Error::TargetDown, res
        when 401
          raise Error::HTTPAuthRequired
        when 403
          raise Error::AccessForbidden, NS::ParsedCli.random_user_agent unless NS::ParsedCli.force
        when 407
          raise Error::ProxyAuthRequired
        end

        # Checks for redirects
        # An out of scope redirect will raise an Error::HTTPRedirect
        effective_url = target.homepage_res.effective_url

        return if target.in_scope?(effective_url)

        raise Error::HTTPRedirect, effective_url unless NS::ParsedCli.ignore_main_redirect

        target.homepage_res = res
      end

      def run
        @start_time = Time.now
        @start_memory = NS.start_memory

        output('started', url: target.url, ip: target.ip, effective_url: target.homepage_url)
      end

      def after_scan
        @stop_time   = Time.now
        @elapsed     = @stop_time - @start_time
        @used_memory = GetProcessMem.new.bytes - @start_memory

        output('finished',
               cached_requests: NS.cached_requests,
               requests_done: NS.total_requests,
               data_sent: NS.total_data_sent,
               data_received: NS.total_data_received)
      end
    end
  end
end
