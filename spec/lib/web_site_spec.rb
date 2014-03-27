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

      web_site.should_not be_online
    end

    it 'returns true when online' do
      stub_request(:get, url).to_return(status: 200)

      web_site.should be_online
    end
  end

  describe '#basic_auth?' do
    it 'returns true if basic auth is detected' do
      stub_request(:get, url).to_return(status: 401)

      web_site.should be_basic_auth
    end

    it 'returns false otherwise' do
      stub_request(:get, url).to_return(status: 200)

      web_site.should_not be_basic_auth
    end
  end

  describe '#redirection' do
    it 'returns nil if no redirection detected' do
      stub_request(:get, web_site.url).to_return(status: 200, body: '')

      web_site.redirection.should be_nil
    end

    [301, 302].each do |status_code|
      it "returns http://new-location.com if the status code is #{status_code}" do
        new_location = 'http://new-location.com'

        stub_request(:get, web_site.url)
          .to_return(status: status_code, headers: { location: new_location })

        stub_request(:get, new_location).to_return(status: 200)

        web_site.redirection.should eq new_location
      end
    end

    context 'when multiple redirections' do
      it 'returns the last redirection' do
        first_redirection = 'www.redirection.com'
        last_redirection  = 'redirection.com'

        stub_request(:get, web_site.url)
          .to_return(status: 301, headers: { location: first_redirection })

        stub_request(:get, first_redirection)
          .to_return(status: 302, headers: { location: last_redirection })

        stub_request(:get, last_redirection).to_return(status: 200)

        web_site.redirection.should eq last_redirection
      end
    end
  end

end
