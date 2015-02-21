module CMSScanner
  module Finders
    class Finder
      # Module to provide an easy way to enumerate items such as plugins, themes etc
      module Enumerator
        # @param [ Hash ] opts
        # @option opts [ Boolean ] :show_progression Wether or not to display the progress bar
        # @option opts [ Regexp ] :exclude_content
        #
        # @yield [ Typhoeus::Response, String ]
        def enumerate(opts = {})
          targets = target_urls(opts)
          bar     = progress_bar(targets.size) if opts[:show_progression]

          targets.each do |url, id|
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

        # @param [ Hash ] opts
        #
        # @return [ Hash ]
        def target_urls(_opts = {})
          fail NotImplementedError
        end

        # @param [ Integer ] total
        #
        # @return [ ProgressBar ]
        # :nocov:
        def progress_bar(total)
          ProgressBar.create(
            format: '%t %a <%B> (%c / %C) %P%% %e',
            title: ' ', # Used to craete a left margin
            total: total
          )
        end
        # :nocov:

        # @return [ CMSScanner::Browser ]
        def browser
          @browser ||= NS::Browser.instance
        end

        def request_params
          # disabling the cache, as it causes a 'stack level too deep' exception
          # with a large number of requests :/
          # See https://github.com/typhoeus/typhoeus/issues/408
          { cache_ttl: 0 }
        end

        # @return [ Typhoeus::Hydra ]
        def hydra
          @hydra ||= browser.hydra
        end
      end
    end
  end
end
