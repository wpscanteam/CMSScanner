# frozen_string_literal: true

module CMSScanner
  # Scope system logic
  class Target < WebSite
    # @return [ Array<PublicSuffix::Domain, String> ]
    def scope
      @scope ||= Scope.new
    end

    # @param [ String ] url An absolute URL
    #
    # @return [ Boolean ] true if the url given is in scope
    def in_scope?(url)
      scope.include?(Addressable::URI.parse(url.strip).host)
    rescue StandardError
      false
    end

    # @param [ Typhoeus::Response ] res
    # @param [ String ] xpath
    #
    # @yield [ String, Nokogiri::XML::Element ] The in scope url and its associated tag
    #
    # @return [ Array<String> ] The in scope absolute URLs detected in the response's body
    def in_scope_urls(res, xpath = '//@href|//@src|//@data-src')
      found = []

      urls_from_page(res, xpath) do |url, tag|
        next unless in_scope?(url)

        yield url, tag if block_given?

        found << url
      end

      found
    end

    # Similar to Target#url_pattern but considering the in scope domains as well
    #
    # @return [ Regexp ]
    def scope_url_pattern
      return @scope_url_pattern if @scope_url_pattern

      domains = [uri.host + uri.path] + scope.domains[1..-1]&.map(&:to_s) + scope.invalid_domains

      domains.map! { |d| Regexp.escape(d.gsub(%r{/$}, '')).sub('\*', '.*') }

      @scope_url_pattern = %r{https?://(?:#{domains.join('|')})/?}i
    end

    # Scope Implementation
    class Scope
      # @return [ Array<PublicSuffix::Domain> ] The valid domains in scope
      def domains
        @domains ||= []
      end

      # @return [ Array<String> ] The invalid domains in scope (such as IP addresses etc)
      def invalid_domains
        @invalid_domains ||= []
      end

      def <<(element)
        if PublicSuffix.valid?(element, ignore_private: true)
          domains << PublicSuffix.parse(element, ignore_private: true)
        else
          invalid_domains << element
        end
      end

      # @return [ Boolean ] Wether or not the host is in the scope
      def include?(host)
        if PublicSuffix.valid?(host, ignore_private: true)
          domain = PublicSuffix.parse(host, ignore_private: true)

          domains.each { |d| return true if domain.match(d) }
        else
          invalid_domains.each { |d| return true if host == d }
        end

        false
      end
    end
  end
end
