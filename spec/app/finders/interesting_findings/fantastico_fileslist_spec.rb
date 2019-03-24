# frozen_string_literal: true

describe CMSScanner::Finders::InterestingFindings::FantasticoFileslist do
  subject(:finder) { described_class.new(target) }
  let(:target)     { CMSScanner::Target.new(url) }
  let(:url)        { 'http://example.com/' }
  let(:file_url)   { url + 'fantastico_fileslist.txt' }
  let(:fixtures)   { FIXTURES_FINDERS.join('interesting_findings', 'fantastico_fileslist') }

  before { expect(finder.target).to receive(:head_or_get_params).and_return(method: :head) }

  describe '#aggressive' do
    before do
      stub_request(:head, file_url).to_return(status: head_status)
    end

    context 'when 404' do
      let(:head_status) { 404 }

      its(:aggressive) { should eql nil }
    end

    context 'when 200' do
      let(:head_status) { 200 }

      context 'when body is empty' do
        it 'returns nil' do
          stub_request(:get, file_url).to_return(status: 200, body: '')

          expect(finder.aggressive).to eql nil
        end
      end

      context 'when not a text/plain Content-Type' do
        it 'return nil' do
          stub_request(:get, file_url)
            .to_return(status: 200, body: 'not empty', headers: { 'Content-Type' => 'text/html ' })

          expect(finder.aggressive).to eql nil
        end
      end

      context 'when the body matches and Content-Type = text/plain' do
        it 'returns the InterestingFinding object' do
          stub_request(:get, file_url)
            .to_return(body: File.read(fixtures.join('fantastico_fileslist.txt')),
                       headers: { 'Content-Type' => 'text/plain' })

          expect(finder.aggressive).to eql CMSScanner::Model::FantasticoFileslist.new(
            file_url,
            confidence: 70,
            found_by: 'Fantastico Fileslist (Aggressive Detection)'
          )
        end
      end
    end
  end
end
