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
      :random_user_agent,
      :request_timeout,
      :user_agent,
      :user_agents_list,
      :vhost
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

    # @return [ String ] The path to the user agents list
    def user_agents_list
      @user_agents_list ||= File.join(APP_DIR, 'user_agents.txt')
    end

    # @return [ Array<String> ]
    def user_agents
      return @user_agents if @user_agents

      @user_agents = []

      File.open(user_agents_list).each do |line|
        next if line == "\n" || line[0, 1] == '#'
        @user_agents << line.chomp
      end

      @user_agents
    end

    # @return [ String ]
    def default_user_agent
      "#{NS} v#{NS::VERSION}"
    end

    # @return [ String ] The user agent
    def user_agent
      @user_agent ||= random_user_agent ? user_agents.sample : default_user_agent
    end
  end
end
