module CMSScanner
  module Finders
    module InterestingFile
      # XML RPC finder
      class XMLRPC < Finder
        # @return [ Array<String> ] The potential urls to the XMl RPC file
        def potential_urls
          @potential_urls ||= []
        end

        def passive(opts = {})
          [passive_headers(opts), passive_body(opts)].compact
        end

        #
        ## TODO: Ensure that the potential URLs found are in scope !!!
        #

        def passive_headers(_opts = {})
          headers = Browser.get(target.url).headers

          return unless headers.key?('X-Pingback')

          url = headers['X-Pingback']

          return unless url && url.length > 0

          potential_urls << url

          CMSScanner::XMLRPC.new(url, confidence: 30, found_by: 'Headers (passive detection)')
        end

        def passive_body(_opts = {})
          page = Nokogiri::HTML(Browser.get(target.url).body)

          page.css('link[rel="pingback"]').each do |tag|
            url = tag.attribute('href').to_s

            next unless url && url.length > 0

            potential_urls << url

            return CMSScanner::XMLRPC.new(url, confidence: 30,
                                               found_by: 'Link Tag (passive detection)')
          end
          nil
        end

        # @return [ InterestingFile ]
        def aggressive(_opts = {})
          potential_urls << target.uri.join('xmlrpc.php').to_s

          potential_urls.uniq.each do |potential_url|
            res = Browser.get(potential_url)

            next unless res && res.body =~ /XML-RPC server accepts POST requests onl/i

            return CMSScanner::XMLRPC.new(potential_url,
                                          confidence: 100,
                                          found_by: 'Direct File Access (agressive detection)')
          end
        end
      end
    end
  end
end
