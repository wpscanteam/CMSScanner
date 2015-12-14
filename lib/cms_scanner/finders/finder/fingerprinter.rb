module CMSScanner
  module Finders
    class Finder
      # Module to provide an easy way to fingerprint things such as versions
      module Fingerprinter
        # @param [ Hash ] fingerprints The fingerprints
        # Format should be the following:
        # {
        #   file_path_1: {
        #     md5_hash_1: version_1,
        #     md5_hash_2: [version_2]
        #   },
        #   file_path_2: {
        #     md5_hash_3: [version_1, version_2],
        #     md5_hash_4: version_3
        #   }
        # }
        # Note that the version can either be an array or a string
        #
        # @param [ Hash ] opts
        # @option opts [ Boolean ] :show_progression Wether or not to display the progress bar
        #
        # @yield [ Mixed, String, String ] version/s, url, hash The version associated to the
        #                                                       fingerprint of the url
        def fingerprint(fingerprints, opts = {})
          create_progress_bar(opts.merge(total: fingerprints.size)) # if opts[:show_progression]

          fingerprints.each do |path, f|
            url     = target.url(path.dup)
            request = browser.forge_request(url, request_params)

            request.on_complete do |res|
              progress_bar.increment

              md5sum = hexdigest(res.body)

              next unless f.key?(md5sum)

              yield f[md5sum], url, md5sum
            end

            hydra.queue(request)
          end

          hydra.run
        end

        # @return [ Hash ]
        def request_params
          {}
        end

        # @return [ String ] The hashed value for the given body
        def hexdigest(body)
          Digest::MD5.hexdigest(body)
        end
      end
    end
  end
end
