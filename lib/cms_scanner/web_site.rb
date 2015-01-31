module CMSScanner
  # WebSite Implementation
  class WebSite
    attr_reader :uri

    def initialize(site_url)
      self.url = site_url.dup
    end

    def url=(site_url)
      # Add a trailing slash to the site url
      site_url << '/' if site_url[-1, 1] != '/'

      # Use the validator to ensure the site_url has a correct format
      OptParseValidator::OptURL.new([]).validate(site_url)

      @uri = Addressable::URI.parse(site_url)
    end

    # Used for convenience
    #
    # @param [ String ] path Optional path to merge with the uri
    #
    # @return [ String ]
    def url(path = nil)
      @uri.join(path || '').to_s
    end

    # Checks if the remote website is up.
    #
    # @return [ Boolean ]
    def online?
      NS::Browser.get(url).code != 0
    end

    # @return [ Boolean ]
    def http_auth?
      NS::Browser.get(url).code == 401
    end

    # @return [ Boolean ]
    def proxy_auth?
      NS::Browser.get(url).code == 407
    end

    # @param [ String ] url
    #
    # @return [ String ] The redirection url or nil
    #
    # As webmock does not allow mocking of redirects, coverage is ignored
    # :nocov:
    def redirection(url = nil)
      url ||= @uri.to_s
      res   = NS::Browser.get(url, followlocation: true)

      res.effective_url == url ? nil : res.effective_url
    end
    # :nocov:
  end
end
