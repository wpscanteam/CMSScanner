module CMSScanner
  # HTTP Authentication Required Error
  class HTTPAuthRequiredError < StandardError
    def to_s
      'HTTP authentication required (or was invalid), please provide it with --http-auth'
    end
  end

  # Proxy Authentication Required Error
  class ProxyAuthRequiredError < StandardError
    def to_s
      'Proxy authentication required (or was invalid), please provide it with --proxy-auth'
    end
  end

  # Access Forbidden Error
  class AccessForbiddenError < StandardError
    def to_s
      'The target is responding with a 403, this might be due to a WAF. ' \
      'Please re-try with --random-user-agent'
    end
  end

  # HttpRedirect Error
  class HttpRedirectError < StandardError
    attr_reader :redirect_uri

    # @param [ String ] url
    def initialize(url)
      @redirect_uri = Addressable::URI.parse(url).normalize
    end

    def to_s
      "The URL supplied redirects to #{redirect_uri}"
    end
  end
end
