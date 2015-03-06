module CMSScanner
  module Finders
    class Finder
      # Module to provide an easy way to enumerate items such as plugins, themes etc
      module Enumerator
        # @param [ Hash ] The target urls
        # @param [ Hash ] opts
        # @option opts [ Boolean ] :show_progression Wether or not to display the progress bar
        # @option opts [ Regexp ] :exclude_content
        #
        # @yield [ Typhoeus::Response, String ]
        def enumerate(target_urls, opts = {})
          bar = progress_bar(total: target_urls.size) if opts[:show_progression]

          target_urls.each do |url, id|
            request = browser.forge_request(url, request_params)

            request.on_complete do |res|
              bar.progress += 1 if opts[:show_progression]

              next if target.homepage_or_404?(res)
              next if opts[:exclude_content] && res.body.match(opts[:exclude_content])

              yield res, id
            end

            hydra.queue(request)
          end

          hydra.run
        end

        # @return [ Hash ]
        def request_params
          # disabling the cache, as it causes a 'stack level too deep' exception
          # with a large number of requests :/
          # See https://github.com/typhoeus/typhoeus/issues/408
          { cache_ttl: 0 }
        end
      end
    end
  end
end
