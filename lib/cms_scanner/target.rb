require 'cms_scanner/web_site'

module CMSScanner
  # Target to Scan
  class Target < WebSite
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
