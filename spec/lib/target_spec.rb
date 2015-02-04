require 'spec_helper'

describe CMSScanner::Target do
  subject(:target) { described_class.new(url) }
  let(:url)        { 'http://e.org' }

  describe '#interesting_files' do
    before do
      expect(CMSScanner::Finders::InterestingFiles).to receive(:find).and_return(stubbed)
    end

    context 'when no findings' do
      let(:stubbed) { [] }

      its(:interesting_files) { should eq stubbed }
    end

    context 'when findings' do
      let(:stubbed) { ['yolo'] }

      it 'allows findings to be added with <<' do
        expect(target.interesting_files).to eq stubbed

        target.interesting_files << 'other-finding'

        expect(target.interesting_files).to eq(stubbed << 'other-finding')
      end
    end
  end
end
