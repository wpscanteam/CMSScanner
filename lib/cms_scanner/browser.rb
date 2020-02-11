# frozen_string_literal: true

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
      self.throttle = 0

      load_options(parsed_options.dup)
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

    # @return [ Hash ] The request params used to connect tothe  target as well as potential other systems such as API
    def default_connect_request_params
      params = {}

      if disable_tls_checks
        # See http://curl.haxx.se/libcurl/c/CURLOPT_SSL_VERIFYHOST.html
        params[:ssl_verifypeer] = false
        params[:ssl_verifyhost] = 0
        # TLSv1.0 and plus, allows to use a protocol potentially lower than the OS default
        params[:sslversion] = :tlsv1
      end

      {
        connecttimeout: :connect_timeout, cache_ttl: :cache_ttl,
        proxy: :proxy, timeout: :request_timeout
      }.each do |typhoeus_opt, browser_opt|
        attr_value = public_send(browser_opt)
        params[typhoeus_opt] = attr_value unless attr_value.nil?
      end

      params
    end

    # @return [ Hash ]
    # The params are not cached (using @params ||= for example), so that they are set accordingly if updated
    # by a controller/other piece of code
    def default_request_params
      params = default_connect_request_params.merge(
        headers: { 'User-Agent' => user_agent, 'Referer' => url }.merge(headers || {}),
        accept_encoding: 'gzip, deflate',
        method: :get
      )

      { cookiejar: :cookie_jar, cookiefile: :cookie_jar, cookie: :cookie_string }.each do |typhoeus_opt, browser_opt|
        attr_value = public_send(browser_opt)
        params[typhoeus_opt] = attr_value unless attr_value.nil?
      end

      params[:proxyuserpwd] = "#{proxy_auth[:username]}:#{proxy_auth[:password]}" if proxy_auth
      params[:userpwd] = "#{http_auth[:username]}:#{http_auth[:password]}" if http_auth

      params[:headers]['Host'] = vhost if vhost

      params
    end

    # @param [ Hash ] params
    #
    # @return [ Hash ]
    def request_params(params = {})
      default_request_params.merge(params) do |key, oldval, newval|
        key == :headers ? oldval.merge(newval) : newval
      end
    end
  end
end
