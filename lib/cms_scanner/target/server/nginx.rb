module CMSScanner
  class Target < WebSite
    module Server
      # Some Nginx specific implementation
      module Nginx
        # @param [ String ] path
        # @param [ Hash ] params The request params
        #
        # @return [ Symbol ] :Nginx
        def server(_path = nil, _params = {})
          :Nginx
        end

        # @param [ String ] path
        # @param [ Hash ] params The request params
        #
        # @return [ Array<String> ] The first level of directories/files listed,
        #                           or an empty array if none
        def directory_listing_entries(path = nil, params = {})
          return [] unless directory_listing?(path, params)

          found = []

          NS::Browser.get(url(path), params).html.css('pre a').each do |node|
            found << node.text.to_s
          end

          found[1..-1] # returns the array w/o the first element '..'
        end
      end
    end
  end
end
