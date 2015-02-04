require 'cms_scanner/web_site'
require 'cms_scanner/target/platform'
require 'cms_scanner/target/server'
require 'cms_scanner/target/scope'

module CMSScanner
  # Target to Scan
  class Target < WebSite
    include Server::Generic

    # @param [ String ] url
    # @param [ Hash ] opts
    # @option opts [ Array<PublicSuffix::Domain, String> ] :scope
    def initialize(url, opts = {})
      super(url, opts)

      scope << uri.host
      [*opts[:scope]].each { |s| scope << s }
    end

    # TODO: add a force option to re-call the #find rather than return the @interesting_files ?
    #
    # @param [ Hash ] opts
    #
    # @return [ Findings ]
    def interesting_files(opts = {})
      @interesting_files ||= NS::Finders::InterestingFiles.find(self, opts)
    end
  end
end
