module CMSScanner
  class Error < RuntimeError
  end

  # HTTP Authentication Required Error
  class HTTPAuthRequiredError < Error
    # :nocov:
    def to_s
      'HTTP authentication required (or was invalid), please provide it with --http-auth'
    end
    # :nocov:
  end

  # Proxy Authentication Required Error
  class ProxyAuthRequiredError < Error
    # :nocov:
    def to_s
      'Proxy authentication required (or was invalid), please provide it with --proxy-auth'
    end
    # :nocov:
  end

  # Access Forbidden Error
  class AccessForbiddenError < Error
    # :nocov:
    def to_s
      'The target is responding with a 403, this might be due to a WAF. ' \
      'Please re-try with --random-user-agent'
    end
    # :nocov:
  end

  # HTTP Redirect Error
  class HTTPRedirectError < Error
    attr_reader :redirect_uri

    # @param [ String ] url
    def initialize(url)
      @redirect_uri = Addressable::URI.parse(url).normalize
    end

    def to_s
      "The URL supplied redirects to #{redirect_uri}. Use the --ignore-main-redirect "\
      'option to ignore the redirection and scan the target.'
    end
  end
end
