module CMSScanner
  # Target to Scan
  class Target
    attr_accessor :url

    def initialize(url)
      @url = url
    end
  end
end
