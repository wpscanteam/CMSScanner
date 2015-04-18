require 'spec_helper'

describe CMSScanner::WebSite do
  subject(:web_site) { described_class.new(url, opts) }
  let(:url)          { 'http://e.org' }
  let(:opts)         { {} }

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

    context 'when non ascii chars' do
      it 'normalize it' do
        web_site.url = 'http://пример.испытание/'

        expect(web_site.url).to eql 'http://xn--e1afmkfd.xn--80akhbyknj4f/'
      end
    end
  end

  describe '#url' do
    context 'when no path argument' do
      its(:url) { should eql 'http://e.org/' }
    end

    context 'when a path argument' do
      it 'appends the path' do
        expect(web_site.url('file.txt')).to eql "#{url}/file.txt"
      end

      it 'encodes the path' do
        expect(web_site.url('f ile.txt')).to eql "#{url}/f%20ile.txt"
        expect(web_site.url('s/a%.txt')).to eql "#{url}/s/a%25.txt"
        expect(web_site.url('#file.txt#')).to eql "#{url}/%23file.txt%23"
      end

      context 'when relative path' do
        let(:url) { 'http://e.org/dir/' }

        it 'appends it from the host/domain' do
          expect(web_site.url('/sub/file.txt')).to eql 'http://e.org/sub/file.txt'
        end
      end
    end
  end

  describe '#opts' do
    its(:opts) { should eql({}) }

    context 'when opts' do
      let(:opts) { { test: 'mm' } }

      its(:opts) { should eql opts }
    end
  end

  describe '#online?, #http_auth?, #access_forbidden?, #proxy_auth?' do
    before { stub_request(:get, web_site.url(path)).to_return(status: status) }

    [nil, 'file-path.txt'].each do |p|
      context "when path = #{p}" do
        let(:path) { p }

        context 'when response status is a 200' do
          let(:status) { 200 }

          it 'is considered fine' do
            expect(web_site.online?(path)).to be true
            expect(web_site.http_auth?(path)).to be false
            expect(web_site.access_forbidden?(path)).to be false
            expect(web_site.proxy_auth?(path)).to be false
          end
        end

        context 'when offline' do
          let(:status) { 0 }

          it 'returns false' do
            expect(web_site.online?(path)).to be false
          end
        end

        context 'when http auth required' do
          let(:status) { 401 }

          it 'returns true' do
            expect(web_site.http_auth?(path)).to be true
          end
        end

        context 'when access is forbidden' do
          let(:status) { 403 }

          it 'return true' do
            expect(web_site.access_forbidden?(path)).to be true
          end
        end

        context 'when proxy auth required' do
          let(:status) { 407 }

          it 'returns true' do
            expect(web_site.proxy_auth?(path)).to be true
          end
        end
      end
    end
  end
end
