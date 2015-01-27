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
          urls     = []
          homepage = NS::Browser.get_and_follow_location(target.url).html

          homepage.xpath(passive_urls_xpath).each do |node|
            url = node['href'].strip
            # case of relative URLs
            url = target.url(url) unless url =~ /\Ahttps?:/i

            next unless target.in_scope?(url)

            urls << url
          end

          urls.uniq
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

        # @return [ String ]
        def found_by
          "#{self.class.to_s.demodulize.underscore.titleize} " \
          "(#{caller_locations[7].label.capitalize} Detection)"
        end
      end
    end
  end
end
