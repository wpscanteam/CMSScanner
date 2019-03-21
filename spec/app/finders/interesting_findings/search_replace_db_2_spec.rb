# frozen_string_literal: true

describe CMSScanner::Finders::InterestingFindings::SearchReplaceDB2 do
  subject(:finder) { described_class.new(target) }
  let(:target)     { CMSScanner::Target.new(url) }
  let(:url)        { 'http://example.com/' }
  let(:file)       { url + 'searchreplacedb2.php' }
  let(:fixtures)   { FIXTURES_FINDERS.join('interesting_findings', 'search_replace_db_2') }

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
        let(:body) { File.read(fixtures.join('searchreplacedb2.php')) }

        it 'returns the InterestingFinding result' do
          @expected = CMSScanner::Model::InterestingFinding.new(
            file,
            confidence: 100,
            found_by: 'Search Replace Db2 (Aggressive Detection)'
          )
        end
      end
    end
  end
end
