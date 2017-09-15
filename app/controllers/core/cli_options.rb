module CMSScanner
  module Controller
    # CLI Options for the Core Controller
    class Core < Base
      def cli_options
        formats = NS::Formatter.availables

        [
          OptURL.new(['-u', '--url URL', 'The URL to scan'], required: true, default_protocol: 'http'),
          OptBoolean.new(['--ignore-main-redirect', 'Ignore the main redirect if any and scan the target url']),
          OptBoolean.new(%w[-v --verbose]),
          OptFilePath.new(['-o', '--output FILE', 'Output to FILE'], writable: true, exists: false),
          OptChoice.new(['-f', '--format FORMAT',
                         'Output results in the format supplied'], choices: formats),
          OptChoice.new(['--detection-mode MODE'],
                        choices: %w[mixed passive aggressive],
                        normalize: :to_sym,
                        default: :mixed),
          OptArray.new(['--scope DOMAINS',
                        'Comma separated (sub-)domains to consider in scope. ',
                        'Wildcard(s) allowed in the trd of valid domains, e.g: *.target.tld'])
        ] + cli_browser_options
      end

      # @return [ Array<OptParseValidator::OptBase> ]
      def cli_browser_options
        [
          OptString.new(['--user-agent VALUE', '--ua']),
          OptString.new(['--vhost VALUE', 'The virtual host (Host header) to use in requests']),
          OptBoolean.new(['--random-user-agent', '--rua',
                          'Use a random user-agent for each scan']),
          OptFilePath.new(['--user-agents-list FILE-PATH',
                           'List of agents to use with --random-user-agent'], exists: true),
          OptCredentials.new(['--http-auth login:password']),
          OptPositiveInteger.new(['--max-threads VALUE', '-t', 'The max threads to use'],
                                 default: 5),
          OptPositiveInteger.new(['--throttle MilliSeconds', 'Milliseconds to wait before doing another web request. ' \
                                  'If used, the max threads will be set to 1.']),
          OptPositiveInteger.new(['--request-timeout SECONDS', 'The request timeout in seconds'],
                                 default: 60),
          OptPositiveInteger.new(['--connect-timeout SECONDS', 'The connection timeout in seconds'],
                                 default: 30)
        ] + cli_browser_proxy_options + cli_browser_cookies_options + cli_browser_cache_options
      end

      # @return [ Array<OptParseValidator::OptBase> ]
      def cli_browser_proxy_options
        [
          OptProxy.new(['--proxy protocol://IP:port',
                        'Supported protocols depend on the cURL installed']),
          OptCredentials.new(['--proxy-auth login:password'])
        ]
      end

      # @return [ Array<OptParseValidator::OptBase> ]
      def cli_browser_cookies_options
        [
          OptString.new(['--cookie-string COOKIE',
                         'Cookie string to use in requests, ' \
                         'format: cookie1=value1[; cookie2=value2]']),
          OptFilePath.new(['--cookie-jar FILE-PATH', 'File to read and write cookies'],
                          writable: true,
                          exists: false,
                          default: File.join(tmp_directory, 'cookie_jar.txt'))
        ]
      end

      # @return [ Array<OptParseValidator::OptBase> ]
      def cli_browser_cache_options
        [
          OptInteger.new(['--cache-ttl TIME_TO_LIVE', 'The cache time to live in seconds'], default: 600),
          OptBoolean.new(['--clear-cache', 'Clear the cache before the scan']),
          OptDirectoryPath.new(['--cache-dir PATH'],
                               readable: true,
                               writable: true,
                               default: File.join(tmp_directory, 'cache'))
        ]
      end
    end
  end
end
