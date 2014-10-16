module CMSScanner
  class Target < WebSite
    module Platform
      # wp-content & plugins directory implementation
      module WordPress
        attr_writer :content_dir, :plugins_dir

        # @return [ String ] The wp-content directory
        def content_dir
          unless @content_dir
            page        = Nokogiri::HTML(Browser.get(url).body)
            escaped_url = Regexp.escape(url).gsub(/https?/i, 'https?')
            pattern     = %r{#{escaped_url}(.+?)\/(?:themes|plugins|uploads)\/}i

            page.css('link,script,style,img').each do |tag|
              %w(href src).each do |attribute|
                attr_value = tag.attribute(attribute).to_s

                next if attr_value.nil? || attr_value.empty?
                next unless in_scope?(attr_value) && attr_value.match(pattern)

                return @content_dir = Regexp.last_match[1]
              end
            end
          end
          @content_dir
        end

        # @return [ Addressable::URI ]
        def content_uri
          uri.join("#{content_dir}/")
        end

        # @return [ String ]
        def content_url
          content_uri.to_s
        end

        # @return [ String ]
        def plugins_dir
          @plugins_dir ||= "#{content_dir}/plugins"
        end

        # @return [ Addressable::URI ]
        def plugins_uri
          uri.join("#{plugins_dir}/")
        end

        # @return [ String ]
        def plugins_url
          plugins_uri.to_s
        end
      end
    end
  end
end
