module CMSScanner
  class Target < WebSite
    module Platform
      # wp-content & plugins directory implementation
      module WordPress
        def content_dir=(dir)
          @content_dir = dir.chomp('/')
        end

        def plugins_dir=(dir)
          @plugins_dir = dir.chomp('/')
        end

        # @return [ String ] The wp-content directory
        def content_dir
          unless @content_dir
            escaped_url = Regexp.escape(url).gsub(/https?/i, 'https?')
            pattern     = %r{#{escaped_url}(.+?)\/(?:themes|plugins|uploads)\/}i

            NS::Browser.get(url).html.css('link,script,style,img').each do |tag|
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

        # Override of the WebSite#url to consider the custom WP directories
        #
        # @param [ String ] path Optional path to merge with the uri
        #
        # @return [ String ]
        def url(path = nil)
          return @uri.to_s unless path

          if path =~ /wp\-content\/plugins/i
            path.gsub!('wp-content/plugins', plugins_dir)
          elsif path =~ /wp\-content/i
            path.gsub!('wp-content', content_dir)
          end

          super(path)
        end
      end
    end
  end
end
