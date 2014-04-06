module CMSScanner
  # Options available in the Browser
  class Browser
    OPTIONS = [
      :cache_ttl,
      :connect_timeout,
      :http_auth,
      :threads,
      :proxy,
      :proxy_auth,
      :request_timeout,
      :user_agent
    ]

    attr_accessor(*OPTIONS)

    # @param [ Hash ] options
    def load_options(options = {})
      OPTIONS.each do |sym|
        send("#{sym}=", options[sym]) if options[sym]
      end
    end
  end
end
