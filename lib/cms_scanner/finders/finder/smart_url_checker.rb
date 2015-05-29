require 'cms_scanner/finders/finder/smart_url_checker/findings'

module CMSScanner
  module Finders
    class Finder
      # Smart URL Checker
      module SmartURLChecker
        # @param [ Array<String> ] urls
        # @param [ Hash ] opts
        #
        # @return []
        def process_urls(_urls, _opts = {})
          fail NotImplementedError
        end

        # @param [ Hash ] opts
        #
        # @return [ Array<Finding> ]
        def passive(opts = {})
          process_urls(passive_urls(opts), opts)
        end

        # @param [ Hash ] opts
        #
        # @return [ Array<String> ]
        def passive_urls(_opts = {})
          target.in_scope_urls(NS::Browser.get(target.url), passive_urls_xpath)
        end

        # @return [ String ]
        def passive_urls_xpath
          fail NotImplementedError
        end

        # @param [ Hash ] opts
        #
        # @return [ Array<Finding> ]
        def aggressive(opts = {})
          # To avoid scanning the same twice
          urls = aggressive_urls(opts)
          urls -= passive_urls(opts) if opts[:mode] == :mixed

          process_urls(urls, opts)
        end

        # @param [ Hash ] opts
        #
        # @return [ Array<String> ]
        def aggressive_urls(_opts = {})
          fail NotImplementedError
        end
      end
    end
  end
end
