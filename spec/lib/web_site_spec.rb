require 'spec_helper'

describe CMSScanner::WebSite do
  subject(:web_site) { described_class.new(url) }
  let(:url)          { 'http://ex.lo' }

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

        expect(web_site.url).to eq('http://site.com/')
        expect(web_site.uri).to be_a Addressable::URI
      end
    end
  end

  describe '#url' do
    context 'when no path argument' do
      its(:url) { should eql 'http://ex.lo/' }
    end

    context 'when a path argument' do
      it 'appends the path' do
        expect(web_site.url('file.txt')).to eql "#{url}/file.txt"
      end

      context 'when relative path' do
        let(:url) { 'http://ex.lo/dir/' }

        it 'appends it from the host/domain' do
          expect(web_site.url('/sub/file.txt')).to eql 'http://ex.lo/sub/file.txt'
        end
      end
    end
  end

  describe '#online?' do
    context 'when online' do
      before { stub_request(:get, url).to_return(status: 200) }

      it { should be_online }
    end

    context 'when offline' do
      before { stub_request(:get, url).to_return(status: 0) }

      it { should_not be_online }
    end
  end

  describe '#http_auth?' do
    context 'when http auth' do
      before { stub_request(:get, url).to_return(status: 401) }

      it { should be_http_auth }
    end

    context 'when no http auth' do
      before { stub_request(:get, url).to_return(status: 200) }

      it { should_not be_http_auth }
    end
  end

  describe '#proxy_auth?' do
    # Handled in app/controllers/core_spec
  end
end
