require 'spec_helper'

describe CMSScanner::WebSite do

  subject(:web_site) { described_class.new(url) }
  let(:url)          { 'http://example.com' }

  describe '#url=' do
    context 'when the url is incorrect' do

      after do
        expect { web_site.url = @url }.to raise_error Addressable::URI::InvalidURIError
      end

      it 'raises an error if empty' do
        @url = ''
      end

      it 'raises an error if wrong format' do
        @url = 'jj'
      end
    end

    context 'when valid' do
      it 'creates an Addressable object and adds a traling slash' do
        web_site.url = 'http://site.com'
        web_site.url.should eq('http://site.com/')
        web_site.uri.should be_a Addressable::URI
      end
    end
  end

  describe '#online?' do
    it 'returns false when offline' do
      stub_request(:get, url).to_return(status: 0)

      web_site.online?.should be_false
    end

    it 'returns true when online' do
      stub_request(:get, url).to_return(status: 200)

      web_site.online?.should be_true
    end
  end

  describe '#basic_auth?' do
    it 'returns true if basic auth is detected' do
      stub_request(:get, url).to_return(status: 401)

      web_site.basic_auth?.should be_true
    end

    it 'returns false otherwise' do
      stub_request(:get, url).to_return(status: 200)

      web_site.basic_auth?.should be_false
    end
  end

end
