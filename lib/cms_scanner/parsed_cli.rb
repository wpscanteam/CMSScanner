# frozen_string_literal: true

module CMSScanner
  # Class to hold the parsed CLI options and have them available via
  # methods, such as #verbose?, rather than from the hash.
  # This is similar to an OpenStruct, but class wise (rather than instance), and with
  # the logic to update the Browser options accordinly
  class ParsedCli
    # @return [ Hash ]
    def self.options
      @options ||= {}
    end

    # Sets the CLI options, and put them into the Browser as well
    # @param [ Hash ] options
    def self.options=(options)
      @options = options.dup || {}

      NS::Browser.reset
      NS::Browser.instance(@options)
    end

    # @return [ Boolean ]
    def self.verbose?
      options[:verbose] ? true : false
    end

    # Unknown methods will return nil, this is the expected behaviour
    # rubocop:disable Style/MissingRespondToMissing
    def self.method_missing(method_name, *_args, &_block)
      super if method_name == :new

      options[method_name.to_sym]
    end
    # rubocop:enable Style/MissingRespondToMissing
  end
end
