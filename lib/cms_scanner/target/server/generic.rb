module CMSScanner
  class Target < WebSite
    module Server
      # Generic Server methods
      module Generic
        # @param [ String ] path
        # @param [ Hash ] params The request params
        #
        # @return [ Symbol ] The detected remote server (:Apache, :IIS)
        def server(path = nil, params = {})
          headers = headers(path, params)

          return unless headers

          case headers[:server]
          when /\Aapache/i
            :Apache
          when /\AMicrosoft-IIS/i
            :IIS
          when /nginx/
            :Nginx
          end
        end

        # @param [ String ] path
        # @param [ Hash ] params The request params
        #
        # @return [ Hash ] The headers
        def headers(path = nil, params = {})
          # The HEAD method might be rejected by some servers ... maybe switch to GET ?
          NS::Browser.head(url(path), params).headers
        end

        # @param [ String ] path
        # @param [ Hash ] params The request params
        #
        # @return [ Boolean ] true if url(path) has the directory
        #                          listing enabled, false otherwise
        def directory_listing?(path = nil, params = {})
          res = NS::Browser.get(url(path), params)

          res.code == 200 && res.body =~ /<h1>Index of/ ? true : false
        end
      end
    end
  end
end
