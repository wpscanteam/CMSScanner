require 'cms_scanner/browser/actions'
require 'cms_scanner/browser/options'

module CMSScanner
  # Singleton used to perform HTTP/HTTPS request to the target
  class Browser
    extend Actions

    # @param [ Hash ] parsed_options
    #
    # @return [ Void ]
    def initialize(parsed_options = {})
      load_options(parsed_options)

      # TODO: init hydra with options[:threads] || 1
    end

    private_class_method :new

    # @param [ Hash ] parsed_options
    #
    # @return [ Browser ] The instance
    def self.instance(parsed_options = {})
      @@instance ||= new(parsed_options)
    end

    def self.reset
      @@instance = nil
    end

    # @param [ String ] url
    # @param [ Hash ] params
    #
    # @return [ Typhoeus::Request ]
    def forge_request(url, params = {})
      Typhoeus::Request.new(url, request_params(params))
    end

    # @param [ Hash ] params
    #
    # @return [ Hash ]
    def request_params(params = {})
      {
        cache_ttl: cache_ttl,
        connecttimeout: connect_timeout,
        maxredirs: 3, # Prevent infinite self redirection
        # Disable SSL-Certificate checks
        proxy: proxy,
        proxyauth: proxy_auth ? "#{proxy_auth[:username]}:#{proxy_auth[:password]}" : nil,
        ssl_verifypeer: false,
        ssl_verifyhost: 2,
        timeout: request_timeout,
        userpwd: http_auth ? "#{http_auth[:username]}:#{http_auth[:password]}" : nil
      }.merge(params)
      # TODO: add the user-agent
    end
  end
end
