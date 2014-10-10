module CMSScanner
  class Target < WebSite
    module Platform
      # Some PHP specific implementation
      module PHP
        DEBUG_LOG_PATTERN = /\[[^\]]+\] PHP (?:Warning|Error|Notice):/
        FPD_PATTERN       = /Fatal error:.+? in (.+?) on/

        # @param [ String ] path
        # @param [ Hash ] prams The request params
        #
        # @return [ Boolean ] true if the path is a debug log, false otherwise
        def debug_log?(path, params = {})
          res = NS::Browser.get(url(path), params.merge(headers: { 'range' => 'bytes=0-700' }))

          res.body =~ DEBUG_LOG_PATTERN ? true : false
        end

        # @param [ String ] path
        # @param [ Hash ] prams The request params
        #
        # @return [ Boolean ] true if url(path) contains a FPD, false otherwise
        def full_path_disclosure?(path, params = {})
          !full_path_disclosure_entries(path, params).empty?
        end

        # @param [ String ] path
        # @param [ Hash ] prams The request params
        #
        # @return [ Array<String> ] The FPD found, or an empty if none
        def full_path_disclosure_entries(path, params = {})
          res = NS::Browser.get(url(path), params)

          res.body.scan(FPD_PATTERN).flatten
        end
      end
    end
  end
end
