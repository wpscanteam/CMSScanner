module Typhoeus
  # Custom Response class
  class Response
    # @return [ Nokogiri::HTML ] The response's body parsed by Nokogiri
    def html
      @html ||= Nokogiri::HTML(body.encode('UTF-8', invalid: :replace, undef: :replace))
    end
  end
end
