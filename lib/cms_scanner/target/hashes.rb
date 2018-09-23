module CMSScanner
  # Scope system logic
  class Target < WebSite
    # @note Comments are deleted to avoid cache generation details
    #
    # @param [ Typhoeus::Response, String ] page
    #
    # @return [ String ] The md5sum of the page
    def self.page_hash(page)
      page = NS::Browser.get(page, followlocation: true) unless page.is_a?(Typhoeus::Response)

      # Removes comments and script tags before computing the hash
      # to remove any potential cached stuff
      html = Nokogiri::HTML(page.body)
      html.xpath('//script|//comment()').each(&:remove)

      Digest::MD5.hexdigest(html)
    end

    # @return [ String ] The hash of the homepage
    def homepage_hash
      @homepage_hash ||= self.class.page_hash(url)
    end

    # @note This is used to detect potential custom 404 responding with a 200
    # @return [ String ] The hash of a 404
    def error_404_hash
      @error_404_hash ||= self.class.page_hash(non_existant_page_url)
    end

    # @return [ String ] The URL of an unlikely existant page
    def non_existant_page_url
      uri.join(Digest::MD5.hexdigest(rand(999_999_999).to_s) + '.html').to_s
    end

    # @param [ Typhoeus::Response, String ] page
    # @return [ Boolean ] Wether or not the page is a the homepage or a 404 based on its md5sum
    def homepage_or_404?(page)
      md5sum = self.class.page_hash(page)

      md5sum == homepage_hash || md5sum == error_404_hash
    end
  end
end
