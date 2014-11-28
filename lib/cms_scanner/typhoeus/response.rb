module Typhoeus
  # Custom Response class
  class Response
    # @return [ Nokogiri::HTML ] The response's body parsed by Nokogiri
    def html
      Nokogiri::HTML(body)
    end
  end
end
