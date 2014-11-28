%w(custom_directories).each do |required|
  require "cms_scanner/target/platform/wordpress/#{required}"
end

module CMSScanner
  class Target < WebSite
    module Platform
      # Some WordPress specific implementation
      module WordPress
        include PHP

        WORDPRESS_PATTERN = %r{/(?:(?:wp-content/(?:themes|plugins|uploads))|wp-includes)/}i

        def wordpress?
          page = Nokogiri::HTML(Browser.get(url).body)

          page.css('script, link').each do |tag|
            tag_url = tag.attribute('href').to_s

            next unless in_scope?(tag_url)

            tag_uri = Addressable::URI.parse(tag_url)

            return true if tag_uri.path =~ WORDPRESS_PATTERN
          end
          false
        end

        def wordpress_hosted?
          uri.host =~ /wordpress.com$/i ? true : false
        end
      end
    end
  end
end
