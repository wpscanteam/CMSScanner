require 'spec_helper'

describe CMSScanner::XMLRPC do
  subject(:xml_rpc) { described_class.new(url) }
  let(:url)      { 'http://example.com/xmlrpc' }

  describe '#request_body' do
    after { expect(xml_rpc.request_body(method, params)).to eq @expected }

    let(:method) { 'rpc-test' }
    let(:params) { [] }

    context 'when no params' do
      it 'returns the body w/o the params elements' do
        @expected = '<?xml version="1.0"?><methodCall>'
        @expected << "<methodName>#{method}</methodName>"
        @expected << '</methodCall>'
      end
    end

    context 'when params' do
      let(:params) { %w(p1 p2) }

      it 'returns the correct body' do
        @expected = '<?xml version="1.0"?><methodCall>'
        @expected << "<methodName>#{method}</methodName><params>"
        @expected << '<param><value><string>p1</string></value></param>'
        @expected << '<param><value><string>p2</string></value></param>'
        @expected << '</params></methodCall>'
      end
    end
  end

  describe '#call' do
    let(:method) { 'rpc-test' }

    it 'returns a Typhoeus::Response' do
      stub_request(:post, url).with(body: xml_rpc.request_body(method)).to_return(body: 'OK')

      response = xml_rpc.call(method)

      expect(response).to be_a Typhoeus::Response
      expect(response.body).to eq 'OK'
    end
  end
end
