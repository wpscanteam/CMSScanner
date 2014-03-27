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

    # See if the remote url returns 30x redirect
    # This method is recursive
    #
    # @param [ String ] url
    #
    # @return [ String ] The redirection url or nil
    def redirection(url = nil)
      url    ||= @uri.to_s
      response = Browser.get(url)

      if response.code == 301 || response.code == 302
        redirection = response.headers_hash['location']

        # Let's check if there is a redirection in the redirection
        if (other_redirection = redirection(redirection))
          redirection = other_redirection
        end
      end

      redirection
    end
  end
end
