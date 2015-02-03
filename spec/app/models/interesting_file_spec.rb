require 'spec_helper'

describe CMSScanner::InterestingFile do
  it_behaves_like CMSScanner::Finders::Finding

  subject(:file) { described_class.new(url, opts) }
  let(:opts)     { {} }
  let(:url)      { 'http://example.com/' }
  let(:fixtures) { File.join(FIXTURES, 'interesting_files') }

  describe '#entries' do
    after do
      stub_request(:get, file.url).to_return(headers: headers, body: @body)

      expect(file.entries).to eq @expected
    end

    context 'when content-type matches text/plain' do
      let(:headers) { { 'Content-Type' => 'text/plain; charset=utf-8' } }

      it 'returns the file content as an array w/o empty strings' do
        @body     = File.new(File.join(fixtures, 'file.txt')).read
        @expected = ['This is', 'a test file', 'with some content']
      end
    end

    context 'when other content-type' do
      let(:headers) { { 'Content-Type' => 'text.html; charset=utf-8' } }

      it 'returns an empty array' do
        @expected = []
      end
    end
  end

  describe '#==' do
    context 'when same URL' do
      it 'returns true' do
        expect(file == described_class.new(url)).to be true
      end
    end

    context 'when not the same URL' do
      it 'returns false' do
        expect(file == described_class.new('http://e.org')).to be false
      end
    end
  end
end
