# frozen_string_literal: true

module CMSScanner
  module Model
    # XML RPC
    class XMLRPC < InterestingFinding
      # @return [ String ]
      def to_s
        @to_s ||= "XML-RPC seems to be enabled: #{url}"
      end

      # @return [ Browser ]
      def browser
        @browser ||= NS::Browser.instance
      end

      # @return [ Array<String> ]
      def available_methods
        return @available_methods if @available_methods

        @available_methods = []

        res = method_call('system.listMethods').run
        doc = Nokogiri::XML.parse(res.body)

        doc.search('methodResponse params param value array data value string').each do |s|
          @available_methods << s.text
        end

        @available_methods
      end

      # @return [ Boolean ] Whether or not the XMLRPC is enabled
      def enabled?
        !available_methods.empty?
      end

      # @param [ String ] method_name
      # @param [ Array ] method_params
      # @param [ Hash ] request_params
      #
      # @return [ Typhoeus::Request ]
      def method_call(method_name, method_params = [], request_params = {})
        browser.forge_request(
          url,
          request_params.merge(
            method: :post,
            body: ::XMLRPC::Create.new.methodCall(method_name, *method_params)
          )
        )
      end

      # @param [ Array<Array> ] methods_and_params
      # @param [ Hash ] request_params
      #
      # Example of methods_and_params:
      # [
      #   [method1, param1, param2],
      #   [method2, param1],
      #   [method3]
      # ]
      #
      # @return [ Typhoeus::Request ]
      def multi_call(methods_and_params = [], request_params = {})
        browser.forge_request(
          url,
          request_params.merge(
            method: :post,
            body: ::XMLRPC::Create.new.methodCall(
              'system.multicall',
              methods_and_params.collect { |m| { methodName: m[0], params: m[1..-1] } }
            )
          )
        )
      end
    end
  end
end
