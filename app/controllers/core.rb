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

        handle_redirection(res)
      end

      def handle_scheme_change(effective_url, effective_uri)
        # Case of http://a.com => https://a.com (or the opposite)
        if !NS::ParsedCli.ignore_main_redirect && target.uri.domain == effective_uri.domain &&
           target.uri.path == effective_uri.path && target.uri.scheme != effective_uri.scheme

          target.url = effective_url
        end
      end

      # Checks if the effective_uri contains a SAMLRequest
      #
      # @param [ Addressable::URI ] effective_uri
      #
      # @return [ Boolean ]
      def saml_request?(effective_uri)
        return false unless effective_uri

        effective_uri.to_s.match?(/[?&]SAMLRequest/i)
      end

      # Builds the command to run the authenticated scan
      #
      # @param [ String ] cookie_string
      # @param [ String ] target_url
      #
      # @return [ String ] The command to run
      def build_command(cookie_string, target_url)
        # Filter out --expect-saml, --cookie-string, and --no-banner flags from the original options
        filtered_options = ARGV.reject do |arg|
          arg.start_with?('--expect-saml', '--cookie-string', '--no-banner')
        end.join(' ')

        # Build the command
        "wpscan --url #{target_url} --cookie-string '#{cookie_string}' --no-banner #{filtered_options}"
      end


      # Handle redirect if the target contains 'SAMLRequest', indicating a need for SAML authentication.
      #
      # @param [ Addressable::URI ] effective_uri
      # @raise [ Error::SAMLAuthenticationRequired ] If the effective_uri contains 'SAMLRequest'
      #
      # @return [ Void ]
      def handle_saml_authentication(effective_uri)
        # If we ended up here, the cookie_string is set, and no --expect-saml flag was included
        raise Error::SAMLAuthenticationFailed if NS::ParsedCli.cookie_string && !NS::ParsedCli.expect_saml
        # If we ended up here but no --expect-saml flag was included
        raise Error::SAMLAuthenticationRequired unless NS::ParsedCli.expect_saml

        # Authenticate using the ferrum browser
        cookie_string = BrowserAuthenticator.authenticate(effective_uri.to_s)
        target_url    = target.url # Needed for overriding in tests
        command       = build_command(cookie_string, target_url)

        # Restart the scan with the cookies set and pass in the original options filtered
        raise Error::AuthenticatedRescanFailure, command unless Kernel.system(command)

        exit(NS::ExitCode::OK)
      end

      # Checks for redirects, an out of scope redirect will raise an Error::HTTPRedirect
      #
      # @param [ Typhoeus::Response ] res
      def handle_redirection(res)
        effective_url = target.homepage_res.effective_url # Basically get and follow location of target.url
        effective_uri = Addressable::URI.parse(effective_url)

        if NS::ParsedCli.expect_saml && !saml_request?(effective_uri)
          puts 'SAML authentication was expected but not required.'
          puts # New line to serve as buffer before the scan results start
        end

        handle_saml_authentication(effective_uri) if saml_request?(effective_uri)
        handle_scheme_change(effective_url, effective_uri)
        return if target.in_scope?(effective_url)

        raise Error::HTTPRedirect, effective_url unless NS::ParsedCli.ignore_main_redirect

        # Sets back homepage_res to unfollowed location in case of ignore_main_redirect used
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
