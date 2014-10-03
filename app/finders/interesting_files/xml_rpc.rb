module CMSScanner
  module Finders
    module InterestingFile
      # XML RPC finder
      class XMLRPC < Finder
        # @return [ Array<String> ] The potential urls to the XMl RPC file
        def potential_urls
          @potential_urls ||= []
        end

        # @return [ Array<XMLRPC> ]
        def passive(opts = {})
          [passive_headers(opts), passive_body(opts)].compact
        end

        # @return [ XMLRPC ]
        def passive_headers(_opts = {})
          url = NS::Browser.get(target.url).headers['X-Pingback']

          return unless target.in_scope?(url)
          potential_urls << url

          NS::XMLRPC.new(url, confidence: 30, found_by: 'Headers (passive detection)')
        end

        # @return [ XMLRPC ]
        def passive_body(_opts = {})
          page = Nokogiri::HTML(NS::Browser.get(target.url).body)

          page.css('link[rel="pingback"]').each do |tag|
            url = tag.attribute('href').to_s

            next unless target.in_scope?(url)
            potential_urls << url

            return NS::XMLRPC.new(url, confidence: 30,
                                       found_by: 'Link Tag (passive detection)')
          end
          nil
        end

        # @return [ XMLRPC ]
        def aggressive(_opts = {})
          potential_urls << target.uri.join('xmlrpc.php').to_s

          potential_urls.uniq.each do |potential_url|
            next unless target.in_scope?(potential_url)

            res = NS::Browser.get(potential_url)

            next unless res && res.body =~ /XML-RPC server accepts POST requests only/i

            return NS::XMLRPC.new(potential_url,
                                  confidence: 100,
                                  found_by: 'Direct File Access (aggressive detection)')
          end
          nil
        end
      end
    end
  end
end
