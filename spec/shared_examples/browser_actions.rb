
shared_examples CMSScanner::Browser::Actions do

  let(:url) { 'http://example.com/file.txt' }

  describe '#get, #post, #head' do
    [:get, :post, :head].each do |method|
      it 'calls the method and returns a Typhoeus::Response' do
        stub_request(method, url).to_return(status: 200)
        CMSScanner::Browser.send(method, url).should be_a Typhoeus::Response
      end
    end
  end

  describe '#get_and_follow_location' do
    let(:redirection) { 'http://redirect.me' }

    it 'follows the location' do
      stub_request(:get, url).to_return(status: 301, headers: { location: redirection })
      stub_request(:get, redirection).to_return(status: 200, body: 'Got me')

      response = CMSScanner::Browser.get_and_follow_location(url)
      response.should be_a Typhoeus::Response
      # Line below is not working due to an issue in Typhoeus/Webmock
      # See https://github.com/typhoeus/typhoeus/issues/279
      # response.body.should eq('Got me')
    end
  end

end
