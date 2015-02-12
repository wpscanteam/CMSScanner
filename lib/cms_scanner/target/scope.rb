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
    rescue
      false
    end

    # @param [ Typhoeus::Response ] res
    # @param [ String ] xpath
    # @param [ Array<String> ] attributes
    #
    # @return [ Array<String> ] The in scope URLs detected in the response's body
    def in_scope_urls(res, xpath = '//link|//script|//style|//img|//a', attributes = %w(href src))
      found = []

      res.html.xpath(xpath).each do |tag|
        attributes.each do |attribute|
          attr_value = tag[attribute]

          next unless attr_value && !attr_value.empty?

          url = uri.join(attr_value.strip).to_s

          next unless in_scope?(url)

          yield url if block_given? && !found.include?(url)
          found << url
        end
      end

      found.uniq
    end

    # Scope Implementation
    class Scope
      # @return [ Array<PublicSuffix::Domain ] The valid domains in scope
      def domains
        @domains ||= []
      end

      # @return [ Array<String> ] The invalid domains in scope (such as IP addresses etc)
      def invalid_domains
        @invalid_domains ||= []
      end

      def <<(element)
        if PublicSuffix.valid?(element)
          domains << PublicSuffix.parse(element)
        else
          invalid_domains << element
        end
      end

      # @return [ Boolean ] Wether or not the host is in the scope
      def include?(host)
        if PublicSuffix.valid?(host)
          domain = PublicSuffix.parse(host)

          domains.each { |d| return true if domain.match(d) }
        else
          invalid_domains.each { |d| return true if host == d }
        end

        false
      end
    end
  end
end
