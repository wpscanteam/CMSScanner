require 'spec_helper'

describe CMSScanner::Finders::InterestingFiles::SearchReplaceDB2 do
  subject(:finder) { described_class.new(target) }
  let(:target)     { CMSScanner::Target.new(url) }
  let(:url)        { 'http://example.com/' }
  let(:file)       { url + 'searchreplacedb2.php' }
  let(:fixtures)   { File.join(FIXTURES_FINDERS, 'interesting_files', 'search_replace_db_2') }

  describe '#url' do
    its(:url) { should eq file }
  end

  describe '#aggressive' do
    after do
      stub_request(:get, file).to_return(status: status, body: body)

      expect(finder.aggressive).to eql @expected
    end

    let(:body) { '' }

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

      context 'when the body matches' do
        let(:body) { File.new(File.join(fixtures, 'searchreplacedb2.php')).read }

        it 'returns the InterestingFile result' do
          @expected = CMSScanner::InterestingFile.new(
            file,
            confidence: 100,
            found_by: 'Search Replace Db2 (Aggressive Detection)'
          )
        end
      end
    end
  end
end
