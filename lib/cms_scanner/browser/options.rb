module Typhoeus
  # Hack to have a setter for the :max_concurrency
  # Which will be officially added in the next version
  # See: https://github.com/typhoeus/typhoeus/issues/366
  class Hydra
    attr_accessor :max_concurrency
  end
end

module CMSScanner
  # Options available in the Browser
  class Browser
    OPTIONS = [
      :cache_ttl,
      :cookie_jar,
      :cookie_string,
      :connect_timeout,
      :http_auth,
      :max_threads,
      :proxy,
      :proxy_auth,
      :request_timeout,
      :user_agent
    ]

    attr_accessor(*OPTIONS)

    # @param [ Hash ] options
    def load_options(options = {})
      OPTIONS.each do |sym|
        send("#{sym}=", options[sym]) if options.key?(sym)
      end
    end

    def hydra
      @hydra ||= Typhoeus::Hydra.new(max_concurrency: max_threads || 1)
    end

    # Set the threads attribute and update
    # the max_concurrency of Typhoeus::Hydra
    #
    # @param [ Integer ] number
    def max_threads=(number)
      @max_threads = number.to_i > 0 ? number.to_i : 1
      hydra.max_concurrency = @max_threads
    end

    # Default user agent
    def user_agent
      @user_agent ||= "CMSScanner v#{VERSION}"
    end
  end
end
