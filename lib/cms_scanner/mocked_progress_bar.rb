module CMSScanner
  # ProgressBar to be used in formatter w/o user_interaction such as
  # JSON etc, to still be able to have a log of messages to output.
  # The object must implement the methods in ruby-progressbar
  # and used in CMSScanner, See https://github.com/jfelchner/ruby-progressbar
  class MockedProgressBar
    attr_reader :increment, :finish

    def self.create(opts = {})
      new(opts)
    end

    def initialize(_opts = {}); end

    # @return [ Integer ]
    def total
      0
    end

    def total=(_total); end

    # @return [ Array<String> ]
    def logs
      @logs ||= []
    end

    # @param [ String, nil ] message
    #
    # @return [ Mixed ]
    def log(message = nil)
      return logs unless message

      logs << message
    end
  end
end
