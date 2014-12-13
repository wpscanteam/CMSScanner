require 'spec_helper'

describe CMSScanner::Finders::InterestingFile::FantasticoFileslist do
  subject(:finder) { described_class.new(target) }
  let(:target)     { CMSScanner::Target.new(url) }
  let(:url)        { 'http://example.com/' }
  let(:file)       { url + 'fantastico_fileslist.txt' }
  let(:fixtures)   { File.join(FIXTURES, 'interesting_files', 'fantastico_fileslist') }

  describe '#url' do
    its(:url) { should eq file }
  end

  describe '#aggressive' do
    after do
      stub_request(:get, file).to_return(status: status, body: body, headers: headers)

      result = finder.aggressive

      expect(result).to be_a CMSScanner::FantasticoFileslist if @expected
      expect(result).to eql @expected
    end

    let(:body)    { '' }
    let(:headers) { { 'Content-Type' => 'text/html ' } }

    context 'when 404' do
      let(:status) { 404 }

      it 'returns nil' do
        @expected = nil
      end
    end

    context 'when 200' do
      let(:status) { 200 }

      context 'when the body is empty' do
        it 'returns nil' do
          @expected = nil
        end
      end

      context 'when not a text/plain Content-Type' do
        let(:body) { 'not an empty body' }

        it 'returns nil' do
          @expected = nil
        end
      end

      context 'when the body matches and Content-Type = text/plain' do
        let(:body)    { File.new(File.join(fixtures, 'fantastico_fileslist.txt')).read }
        let(:headers) { { 'Content-Type' => 'text/plain' } }

        it 'returns the InterestingFile result' do
          @expected = CMSScanner::FantasticoFileslist.new(
            file,
            confidence: 100,
            found_by: 'FantasticoFileslist (aggressive detection)'
          )
        end
      end
    end
  end
end
