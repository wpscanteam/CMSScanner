require 'cms_scanner/web_site'
require 'cms_scanner/target/platform'
require 'cms_scanner/target/server'
require 'cms_scanner/target/scope'
require 'cms_scanner/target/hashes'

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

    # @param [ Hash ] opts
    #
    # @return [ Findings ]
    def interesting_files(opts = {})
      @interesting_files ||= NS::Finders::InterestingFiles::Base.find(self, opts)
    end

    # @param [ Typhoeus::Response, String ] page
    # @param [ Regexp ] pattern
    #
    # @return [ Array<MatchData> ]
    # @yield [ MatchData ]
    def comments_from_page(page, pattern)
      page    = NS::Browser.get(url(page)) unless page.is_a?(Typhoeus::Response)
      matches = []

      page.html.xpath('//comment()').each do |node|
        next unless node.text.to_s.strip =~ pattern

        yield Regexp.last_match if block_given?

        matches << Regexp.last_match
      end

      matches
    end
  end
end
