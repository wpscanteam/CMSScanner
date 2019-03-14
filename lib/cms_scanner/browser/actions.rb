module CMSScanner
  class Browser
    # Browser Actions (get, post etc)
    module Actions
      # @param [ String ] url
      # @param [ Hash ] params
      #
      # @return [ Typhoeus::Response ]
      def get(url, params = {})
        process(url, params.merge(method: :get))
      end

      # @param [ String ] url
      # @param [ Hash ] params
      #
      # @return [ Typhoeus::Response ]
      def post(url, params = {})
        process(url, params.merge(method: :post))
      end

      # @param [ String ] url
      # @param [ Hash ] params
      #
      # @return [ Typhoeus::Response ]
      def head(url, params = {})
        process(url, params.merge(method: :head))
      end

      # @param [ String ] url
      # @param [ Hash ] params
      #
      # @return [ Typhoeus::Response ]
      def get_and_follow_location(url, params = {})
        get(url, { followlocation: true, maxredirs: 3 }.merge(params))
      end

      protected

      # @param [ String ] url
      # @param [ Hash ] params
      #
      # @return [ Typhoeus::Response ]
      def process(url, params)
        Typhoeus::Request.new(url, NS::Browser.instance.request_params(params)).run
      end
    end
  end
end
