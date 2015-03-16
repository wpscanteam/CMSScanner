module CMSScanner
  class Target < WebSite
    module Server
      # Some Apche specific implementation
      module Apache
        # @param [ String ] path
        # @param [ Hash ] params The request params
        #
        # @return [ Symbol ] :Apache
        def server(_path = nil, _params = {})
          :Apache
        end

        # @param [ String ] path
        # @param [ Hash ] params The request params
        #
        # @return [ Array<String> ] The first level of directories/files listed,
        #                           or an empty array if none
        def directory_listing_entries(path = nil, params = {})
          return [] unless directory_listing?(path, params)

          found = []

          NS::Browser.get(url(path), params).html.css('td a').each do |node|
            found << node.text.to_s
          end

          found[1..-1] # returns the array w/o the first element 'Parent Directory'
        end
      end
    end
  end
end
