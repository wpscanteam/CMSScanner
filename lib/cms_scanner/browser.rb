require 'cms_scanner/browser/actions'

module CMSScanner
  # Singleton used to perform HTTP/HTTPS request to the target
  class Browser
    extend Actions

    def initialize
    end

    private_class_method :new

    def self.instance
      @@instance ||= new
    end

    def self.reset
      @@instance = nil
    end

    # @param [ String ] url
    # @param [ Hash ] params
    #
    # @return [ Typhoeus::Request ]
    def forge_request(url, params = {})
      Typhoeus::Request.new(url, merge_request_params(params))
    end

    # @param [ Hash ] params
    #
    # @return [ Hash ]
    def request_params(params = {})
      # Prevent infinite self redirection
      params.merge!(maxredirs: 3) unless params.key?(:maxredirs)

      # Disable SSL-Certificate checks
      params.merge!(ssl_verifypeer: false)
      params.merge!(ssl_verifyhost: 2)

      params
    end
  end
end
