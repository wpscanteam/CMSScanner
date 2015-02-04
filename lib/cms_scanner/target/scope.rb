module CMSScanner
  # Scope system logic
  class Target < WebSite
    # @return [ Array<PublicSuffix::Domain, String> ]
    def scope
      @scope ||= Scope.new
    end

    # // are handled by Addressable::URI, but worngly :/
    # e.g: Addressable::URI.parse('//file').host => file
    #
    # Idea: parse the // with PublicSuffix to see if a valid
    #       domain is used
    #
    # @param [ String ] url
    #
    # @return [ Boolean ] true if the url given is in scope
    def in_scope?(url)
      return true if url[0, 1] == '/' && url[1, 1] != '/'

      scope.include?(Addressable::URI.parse(url).host)
    rescue
      false
    end

    # @param [ Typhoeus::Response ] response
    # @param [ String ] css_selector
    # @param [ Array<String> ] attributes
    #
    # @return [ Array<String> ] The in scope URLs detected in the response's body
    def in_scope_urls(response, css_selector = 'link,script,style,img,a', attributes = %w(href src))
      found = []

      response.html.css(css_selector).each do |tag|
        attributes.each do |attribute|
          attr_value = tag.attribute(attribute).to_s

          next if attr_value.nil? || attr_value.empty?
          next unless in_scope?(attr_value)

          found << attr_value
          yield attr_value if block_given?
        end
      end

      found
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
