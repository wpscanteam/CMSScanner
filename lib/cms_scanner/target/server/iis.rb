module CMSScanner
  class Target < WebSite
    module Server
      # Some IIS specific implementation
      module IIS
        # @param [ String ] path
        # @param [ Hash ] params The request params
        #
        # @return [ Symbol ] :iis
        def server(_path = nil, _params = {})
          :IIS
        end

        # @param [ String ] path
        # @param [ Hash ] params The request params
        #
        # @return [ Boolean ] true if url(path) has the directory
        #                          listing enabled, false otherwise
        def directory_listing?(path = nil, params = {})
          res = NS::Browser.get(url(path), params)

          res.code == 200 && res.body =~ /<H1>#{uri.host} - \// ? true : false
        end

        # @param [ String ] path
        # @param [ Hash ] params The request params
        #
        # @return [ Array<String> ] The first level of directories/files listed,
        #                           or an empty array if none
        def directory_listing_entries(path = nil, params = {})
          return [] unless directory_listing?(path, params)

          doc   = Nokogiri::HTML(NS::Browser.get(url(path), params).body)
          found = []

          doc.css('pre a').each do |node|
            entry = node.text.to_s

            next if entry == '[To Parent Directory]'
            found << entry
          end

          found
        end
      end
    end
  end
end
