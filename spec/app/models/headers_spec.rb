require 'spec_helper'

describe CMSScanner::Headers do
  subject(:file) { described_class.new(url) }
  let(:url)      { 'http://example.com/' }
  let(:fixtures) { File.join(FIXTURES_FINDERS, 'interesting_files', 'headers') }
  let(:fixture)  { File.join(fixtures, 'interesting.txt') }
  let(:headers)  { {} }

  before { stub_request(:get, file.url).to_return(headers: headers) }

  describe '#known_headers' do
    it 'does not contains dupliactes' do
      expect(file.known_headers).to eql file.known_headers.uniq
    end
  end

  describe '#entries' do
    after { expect(file.entries).to eq @expected if @expected }

    context 'when no headers' do
      its(:entries) { should eq({}) }
    end

    context 'when headers' do
      let(:headers) { parse_headers_file(fixture) }

      it 'returns the headers' do
        @expected = headers
      end
    end
  end

  describe '#interesting_entries' do
    after { expect(file.interesting_entries).to eq @expected if @expected }

    context 'when interesting headers' do
      let(:headers) { parse_headers_file(fixture) }

      it 'returns an array with the headers' do
        @expected = ['Server: nginx/1.1.19', 'X-Powered-By: ASP.NET, PHP', 'X-Article-Id: 12']
      end
    end

    context 'when no interesting headers' do
      let(:headers) { parse_headers_file(File.join(fixtures, 'no_interesting.txt')) }

      its(:interesting_entries) { should eq [] }
    end
  end
end
