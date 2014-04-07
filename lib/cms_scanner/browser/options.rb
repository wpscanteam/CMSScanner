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

    def hydra
      @hydra ||= Typhoeus::Hydra.new(max_concurrency: threads || 1)
    end

    # Set the threads attribute and update
    # the max_concurrency of Typhoeus::Hydra
    #
    # /!\ Currently Hydra does not have this setter
    # Issue opened: https://github.com/typhoeus/typhoeus/issues/366
    #
    # @param [ Integer ] number
    # def threads=(number)
    #  # TODO: check if number > 0, if not, set to 1
    #  @threads = number
    #  hydra.max_concurrency = number
    # end
  end
end
