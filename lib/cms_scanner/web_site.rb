module CMSScanner
  # WebSite Implementation
  class WebSite
    attr_reader :uri

    def initialize(site_url)
      # Add a trailing slash to the site url
      site_url << '/' if site_url[-1, 1] != '/'
      self.url = site_url
    end

    def url=(url)
      @uri = Addressable::URI.parse(url)
      fail Addressable::URI::InvalidURIError unless @uri.scheme
    end

    # Used for convenience
    #
    # @return [ String ]
    def url
      @uri.to_s
    end

    # Checks if the remote website is up.
    #
    # @return [ Boolean ]
    def online?
      Browser.get(url).code != 0
    end

    # @return [ Boolean ]
    def basic_auth?
      Browser.get(url).code == 401
    end
  end
end
