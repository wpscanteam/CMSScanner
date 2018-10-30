module Typhoeus
  # Custom Response class
  class Response
    # @return [ Nokogiri::HTML ] The response's body parsed by Nokogiri::HTML
    def html
      @html ||= Nokogiri::HTML(body.encode('UTF-8', invalid: :replace, undef: :replace))
    end

    # @return [ Nokogiri::XML ] The response's body parsed by Nokogiri::XML
    def xml
      @xml ||= Nokogiri::XML(body.encode('UTF-8', invalid: :replace, undef: :replace))
    end

    # @return [ Integer ]
    def length
      body.size + response_headers.size
    end
  end
end
