# frozen_string_literal: true

module CMSScanner
  # WebSite Implementation
  class WebSite
    attr_reader :uri, :opts

    # @param [ String ] site_url
    # @param [ Hash ] opts
    def initialize(site_url, opts = {})
      self.url = +site_url
      @opts    = opts
    end

    def url=(site_url)
      # Add a trailing slash to the site url
      # Making also sure the site_url is unfrozen
      +site_url << '/' if site_url[-1, 1] != '/'

      # Use the validator to ensure the site_url has a correct format
      OptParseValidator::OptURL.new([]).validate(site_url)

      @uri = Addressable::URI.parse(site_url).normalize
    end

    # Used for convenience
    #
    # URI.encode is preferered over Addressable::URI.encode as it will encode
    # leading # character:
    # URI.encode('#t#') => %23t%23
    # Addressable::URI.encode('#t#') => #t%23
    #
    # @param [ String ] path Optional path to merge with the uri
    #
    # @return [ String ]
    def url(path = nil)
      return @uri.to_s unless path

      @uri.join(URI.encode(path)).to_s
    end

    attr_writer :homepage_res

    # @return [ Typhoeus::Response ]
    #
    # As webmock does not support redirects mocking, coverage is ignored
    # :nocov:
    def homepage_res
      @homepage_res ||= NS::Browser.get_and_follow_location(url)
    end
    # :nocov:

    # @return [ String ]
    def homepage_url
      @homepage_url ||= homepage_res.effective_url
    end

    # Checks if the remote website is up.
    #
    # @param [ String ] path
    #
    # @return [ Boolean ]
    def online?(path = nil)
      NS::Browser.get(url(path)).code.nonzero? ? true : false
    end

    # @param [ String ] path
    #
    # @return [ Boolean ]
    def http_auth?(path = nil)
      NS::Browser.get(url(path)).code == 401
    end

    # @param [ String ] path
    #
    # @return [ Boolean ]
    def access_forbidden?(path = nil)
      NS::Browser.get(url(path)).code == 403
    end

    # @param [ String ] path
    #
    # @return [ Boolean ]
    def proxy_auth?(path = nil)
      NS::Browser.get(url(path)).code == 407
    end

    # @param [ String ] url
    #
    # @return [ String ] The redirection url or nil
    #
    # As webmock does not support redirects mocking, coverage is ignored
    # :nocov:
    def redirection(url = nil)
      url ||= @uri.to_s

      return unless [301, 302].include?(NS::Browser.get(url).code)

      res = NS::Browser.get(url, followlocation: true)

      res.effective_url == url ? nil : res.effective_url
    end
    # :nocov:

    # @return [ Hash ] The Typhoeus params to use to perform head requests
    def head_or_get_params
      @head_or_get_params ||= if NS::Browser.head(homepage_url).code == 405
                                { method: :get, maxfilesize: 1 }
                              else
                                { method: :head }
                              end
    end

    # Perform a HEAD request to the path provided, then if its response code
    # is in the array of codes given, a GET is done and the response returned. Otherwise the
    # HEAD response is returned.
    #
    # @param [ String ] path
    # @param [ Array<String> ] codes
    # @param [ Hash ] params The requests params
    # @option params [ Hash ] :head Request params for the HEAD
    # @option params [ hash ] :get Request params for the GET
    #
    # @return [ Typhoeus::Response ]
    def head_and_get(path, codes = [200], params = {})
      url_to_get  = url(path)
      head_params = (params[:head] || {}).merge(head_or_get_params)

      head_res = NS::Browser.instance.forge_request(url_to_get, head_params).run

      codes.include?(head_res.code) ? NS::Browser.get(url_to_get, params[:get] || {}) : head_res
    end
  end
end
