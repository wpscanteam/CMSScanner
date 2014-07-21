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
end
