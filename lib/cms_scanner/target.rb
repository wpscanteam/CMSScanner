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
    def interesting_findings(opts = {})
      @interesting_findings ||= NS::Finders::InterestingFindings::Base.find(self, opts)
    end

    # Weteher or not vulnerabilities have been found.
    # Used to set the exit code of the script
    # and it should be overriden in the implementation
    #
    # @return [ Boolean ]
    def vulnerable?
      false
    end

    # @param [ Regexp ] pattern
    # @param [ Typhoeus::Response, String ] page
    #
    # @return [ Array<Array<MatchData, Nokogiri::XML::Comment>> ]
    # @yield [ MatchData, Nokogiri::XML::Comment ]
    def comments_from_page(pattern, page = nil)
      page    = NS::Browser.get(url(page)) unless page.is_a?(Typhoeus::Response)
      matches = []

      page.html.xpath('//comment()').each do |node|
        next unless node.text.strip =~ pattern

        yield Regexp.last_match, node if block_given?

        matches << [Regexp.last_match, node]
      end

      matches
    end

    # @param [ Typhoeus::Response, String ] page
    # @param [ String ] xpath
    # @param [ Array<String> ] attributes
    #
    # @yield [ String, Nokogiri::XML::Element ] The url and its associated tag
    #
    # @return [ Array<String> ] The absolute URLs detected in the response's body from the HTML tags
    def urls_from_page(page = nil, xpath = '//link|//script|//style|//img|//a', attributes = %w(href src))
      page    = NS::Browser.get(url(page)) unless page.is_a?(Typhoeus::Response)
      found   = []

      page.html.xpath(xpath).each do |tag|
        attributes.each do |attribute|
          attr_value = tag[attribute]

          next unless attr_value && !attr_value.empty?

          tag_uri        = uri.join(attr_value.strip) rescue next
          tag_uri_string = tag_uri.to_s

          next unless tag_uri.host

          yield tag_uri_string, tag if block_given? && !found.include?(tag_uri_string)

          found << tag_uri_string
        end
      end

      found.uniq
    end
  end
end
