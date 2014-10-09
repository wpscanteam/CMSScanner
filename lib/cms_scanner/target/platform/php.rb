module CMSScanner
  class Target < WebSite
    module Platform
      # Some PHP specific implementation
      module PHP
        DEBUG_LOG_PATTERN = /\[[^\]]+\] PHP (?:Warning|Error|Notice):/

        # @param [ String ] path
        #
        # @return [ Boolean ] true if the path is a debug log, false otherwise
        def debug_log?(path, params = {})
          res = NS::Browser.get(url(path), params.merge(headers: { 'range' => 'bytes=0-700' }))

          res.body =~ DEBUG_LOG_PATTERN ? true : false
        end
      end
    end
  end
end
