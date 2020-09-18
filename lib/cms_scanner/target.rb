# frozen_string_literal: true

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
      Array(opts[:scope]).each { |s| scope << s }
    end

    # @param [ Hash ] opts
    #
    # @return [ Findings ]
    def interesting_findings(opts = {})
      @interesting_findings ||= NS::Finders::InterestingFindings::Base.find(self, opts)
    end

    # Weteher or not vulnerabilities have been found.
    # Used to set the exit code of the scanner
    # and it should be overriden in the implementation
    #
    # @return [ Boolean ]
    def vulnerable?
      raise NotImplementedError
    end

    # @return [ Regexp ] The pattern related to the target url, also matches escaped /, such as
    #                    in JSON JS data: http:\/\/t.com\/
    def url_pattern
      @url_pattern ||= Regexp.new(Regexp.escape(url).gsub(/https?/i, 'https?').gsub('/', '\\\\\?/'), Regexp::IGNORECASE)
    end

    # @param [ String ] xpath
    # @param [ Regexp ] pattern
    # @param [ Typhoeus::Response, String ] page
    #
    # @return [ Array<Array<MatchData, Nokogiri::XML::Element>> ]
    # @yield  [ MatchData, Nokogiri::XML::Element ]
    def xpath_pattern_from_page(xpath, pattern, page = nil)
      page    = NS::Browser.get(url(page)) unless page.is_a?(Typhoeus::Response)
      matches = []

      page.html.xpath(xpath).each do |node|
        next unless node.text.strip =~ pattern

        yield Regexp.last_match, node if block_given?

        matches << [Regexp.last_match, node]
      end

      matches
    end

    # @param [ Regexp ] pattern
    # @param [ Typhoeus::Response, String ] page
    #
    # @return [ Array<Array<MatchData, Nokogiri::XML::Comment>> ]
    # @yield  [ MatchData, Nokogiri::XML::Comment ]
    def comments_from_page(pattern, page = nil)
      xpath_pattern_from_page('//comment()', pattern, page) do |match, node|
        yield match, node if block_given?
      end
    end

    # @param [ Regexp ] pattern
    # @param [ Typhoeus::Response, String ] page
    #
    # @return [ Array<Array<MatchData, Nokogiri::XML::Element>> ]
    # @yield  [ MatchData, Nokogiri::XML::Element ]
    def javascripts_from_page(pattern, page = nil)
      xpath_pattern_from_page('//script', pattern, page) do |match, node|
        yield match, node if block_given?
      end
    end

    # @param [ Typhoeus::Response, String ] page
    # @param [ String ] xpath
    #
    # @yield [ Addressable::URI, Nokogiri::XML::Element ] The url and its associated tag
    #
    # @return [ Array<Addressable::URI> ] The absolute URIs detected in the response's body from the HTML tags
    #
    # @note It is highly recommended to use the xpath parameter to focus on the uris needed, as this method can be quite
    #       time consuming when there are a lof of uris to check
    def uris_from_page(page = nil, xpath = '//@href|//@src|//@data-src')
      page    = NS::Browser.get(url(page)) unless page.is_a?(Typhoeus::Response)
      found   = []

      page.html.xpath(xpath).each do |node|
        attr_value = node.text.to_s

        next unless attr_value && !attr_value.empty?

        node_uri = begin
          uri.join(attr_value.strip)
        rescue StandardError
          # Skip potential malformed URLs etc.
          next
        end

        next unless node_uri.host

        yield node_uri, node.parent if block_given? && !found.include?(node_uri)

        found << node_uri
      end

      found.uniq
    end
  end
end
