module CMSScanner
  # WebSite Implementation
  class WebSite
    attr_reader :uri, :opts

    # @param [ String ] site_url
    # @param [ Hash ] opts
    def initialize(site_url, opts = {})
      self.url = site_url.dup
      @opts    = opts
    end

    def url=(site_url)
      # Add a trailing slash to the site url
      site_url << '/' if site_url[-1, 1] != '/'

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
      NS::Browser.get(url(path)).code != 0
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
  end
end
