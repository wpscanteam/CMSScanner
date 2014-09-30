require 'cms_scanner/web_site'

module CMSScanner
  # Target to Scan
  class Target < WebSite
    # @note Subdomains are considered out of scope (maybe consider them in ?)
    # @param [ String ] url
    #
    # @return [ Boolean ] true if the url given belongs to the target
    def in_scope?(url)
      Addressable::URI.parse(url).host == uri.host
    rescue
      false
    end

    # TODO: add a force option to re-call the #find rather than return the @interesting_files ?
    #
    # @param [ Hash ] opts
    #
    # @return [ Findings ]
    def interesting_files(opts = {})
      @interesting_files ||= Finders::InterestingFiles.find(self, opts)
    end
  end
end
