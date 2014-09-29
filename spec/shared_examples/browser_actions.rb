
shared_examples CMSScanner::Browser::Actions do

  let(:url)     { 'http://example.com/file.txt' }
  let(:browser) { CMSScanner::Browser }

  describe '#get, #post, #head' do
    [:get, :post, :head].each do |method|
      it 'calls the method and returns a Typhoeus::Response' do
        stub_request(method, url)

        expect(browser.send(method, url)).to be_a Typhoeus::Response
      end
    end
  end

  describe '#get_and_follow_location' do
    let(:redirection) { 'http://redirect.me' }

    it 'follows the location' do
      stub_request(:get, url).to_return(status: 301, headers: { location: redirection })
      stub_request(:get, redirection).to_return(status: 200, body: 'Got me')

      response = browser.get_and_follow_location(url)
      expect(response).to be_a Typhoeus::Response
      # Line below is not working due to an issue in Typhoeus/Webmock
      # See https://github.com/typhoeus/typhoeus/issues/279
      # expect(response.body).to eq 'Got me'
    end
  end

  describe '#xml_rpc_body' do
    after { expect(browser.xml_rpc_body(method, params)).to eq @expected }

    let(:method) { 'rpc-test' }
    let(:params) { [] }

    context 'when no params' do
      it 'returns the correct body' do
        @expected = '<?xml version="1.0"?><methodCall>'
        @expected << "<methodName>#{method}</methodName>"
        @expected << '</methodCall>'
      end
    end

    context 'when params' do
      let(:params) { %w(p1 p2) }

      it 'returns the right body' do
        @expected = '<?xml version="1.0"?><methodCall>'
        @expected << "<methodName>#{method}</methodName><params>"
        @expected << '<param><value><string>p1</string></value></param>'
        @expected << '<param><value><string>p2</string></value></param>'
        @expected << '</params></methodCall>'
      end
    end
  end

  describe '#xml_rpc_call' do
    let(:rpc_method) { 'rpc-test' }

    it 'returns a Typhoeus::Response' do
      stub_request(:post, url).with(body: browser.xml_rpc_body(rpc_method)).to_return(body: 'OK')

      response = browser.xml_rpc_call(url, rpc_method)

      expect(response).to be_a Typhoeus::Response
      expect(response.body).to eq 'OK'
    end
  end

end
