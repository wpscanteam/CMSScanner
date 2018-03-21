require 'spec_helper'

describe CMSScanner::XMLRPC do
  subject(:xml_rpc) { described_class.new(url) }
  let(:url)         { 'http://example.com/xmlrpc' }
  let(:fixtures)    { File.join(FIXTURES_MODELS, 'xml_rpc') }

  describe '#method_call' do
    after do
      request = xml_rpc.method_call(method, method_params, request_params)

      expect(request).to be_a Typhoeus::Request
      expect(request.options[:body]).to eql @expected_body

      expect(request.options).to include(request_params) unless request_params.empty?
    end

    let(:method)         { 'rpc-test' }
    let(:method_params)  { [] }
    let(:request_params) { {} }

    context 'when no params' do
      it 'sets the correct body in the request' do
        @expected_body = '<?xml version="1.0" ?><methodCall>'
        @expected_body << "<methodName>#{method}</methodName><params/>"
        @expected_body << "</methodCall>\n"
      end
    end

    context 'when method_params and request_params' do
      let(:method_params) { %w[p1 p2] }
      let(:request_params)  { { spec_key: 'yolo' } }

      it 'set the correct body in the request' do
        @expected_body = '<?xml version="1.0" ?><methodCall>'
        @expected_body << "<methodName>#{method}</methodName><params>"
        @expected_body << '<param><value><string>p1</string></value></param>'
        @expected_body << '<param><value><string>p2</string></value></param>'
        @expected_body << "</params></methodCall>\n"
      end
    end
  end

  describe '#multi_call' do
    after do
      request = xml_rpc.multi_call(methods_and_params, request_params)

      expect(request).to be_a Typhoeus::Request
      expect(request.options[:body]).to eql @expected_body

      expect(request.options).to include(request_params) unless request_params.empty?
    end

    let(:methods_and_params) { [%w[m1 p1 p2], %w[m2 p1], %w[m3]] }
    let(:request_params)     { {} }

    it 'sets the correct body in the request' do
      @expected_body = File.read(File.join(fixtures, 'multi_call.xml'))
    end
  end

  describe '#available_methods' do
    xit
  end

  describe '#enabled?' do
    xit
  end
end
