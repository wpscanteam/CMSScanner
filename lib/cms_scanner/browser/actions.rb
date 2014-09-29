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
        get(url, params.merge(followlocation: true))
      end

      # @parm [ String ] url
      # @param [ String ] rpc_method
      # @param [ Array ] rpc_params
      # @param [ Hash ] request_params
      #
      # @return [ Typhoeus::Response ]
      def xml_rpc_call(url, rpc_method, rpc_params = [], request_params = {})
        post(url, request_params.merge(body: xml_rpc_body(rpc_method, rpc_params)))
      end

      # Might be better to use Nokogiri to create the XML body ?
      #
      # @param [ String ] method
      # @param [ Array ] params
      #
      # @return [ String ] The body of the XML RPC request
      def xml_rpc_body(method, params = [])
        p_body = ''

        params.each { |p| p_body << "<param><value><string>#{p}</string></value></param>" }

        body = '<?xml version="1.0"?><methodCall>'
        body << "<methodName>#{method}</methodName>"
        body << "<params>#{p_body}</params>" unless p_body.length == 0
        body << '</methodCall>'
      end

      protected

      # @param [ String ] url
      # @param [ Hash ] params
      #
      # @return [ Typhoeus::Response ]
      def process(url, params)
        Typhoeus::Request.new(url, Browser.instance.request_params(params)).run
      end
    end
  end
end
