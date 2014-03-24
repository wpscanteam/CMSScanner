module CMSScanner
  # WebSite Implementation
  class WebSite
    attr_reader :uri

    def initialize(site_url)
      self.url = site_url
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
