require 'cms_scanner/cache_file_store'

module CMSScanner
  # Cache implementation for Typhoeus
  class TyphoeusCache < CacheFileStore
    # @param [ Typhoeus::Request ] request
    #
    # @return [ Typhoeus::Response ]
    def get(request)
      read_entry(request.hash.to_s)
    end

    # @param [ Typhoeus::Request ] request
    # @param [ Typhoeus::Response ] response
    def set(request, response)
      write_entry(request.hash.to_s, response, request.cache_ttl)
    end
  end
end
