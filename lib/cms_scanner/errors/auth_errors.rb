module CMSScanner
  # HTTP Authentication Required Error
  class HTTPAuthRequiredError < StandardError
    def message
      'HTTP authentication required (or was invalid), please provide it with --http-auth'
    end
  end

  # Proxy Authentication Required Error
  class ProxyAuthRequiredError < StandardError
    def message
      'Proxy authentication required (or was invalid), please provide it with --proxy-auth'
    end
  end

  # Access Forbidden Error
  class AccessForbiddenError < StandardError
    def message
      'The target is responding with a 403, this might be due to a WAF. ' \
      'Please re-try with --random-user-agent'
    end
  end
end
