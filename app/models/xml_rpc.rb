module CMSScanner
  # XML RPC
  class XMLRPC < InterestingFile
    # @param [ String ] method
    # @param [ Array ] params
    # @param [ Hash ] request_params
    #
    # @return [ Typhoeus::Response ]
    def call(method, params = [], request_params = {})
      NS::Browser.post(url, request_params.merge(body: request_body(method, params)))
    end

    # Might be better to use Nokogiri to create the XML body ?
    #
    # @param [ String ] method
    # @param [ Array ] params
    #
    # @return [ String ] The body of the XML RPC request
    def request_body(method, params = [])
      p_body = ''

      params.each { |p| p_body << "<param><value><string>#{p}</string></value></param>" }

      body = '<?xml version="1.0"?><methodCall>'
      body << "<methodName>#{method}</methodName>"
      body << "<params>#{p_body}</params>" unless p_body.length == 0
      body << '</methodCall>'
    end

    # Use the system.listMethods to get the list of available methods ?
    # def entries
    #
    # end
  end
end
