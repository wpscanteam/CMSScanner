require 'spec_helper'

describe CMSScanner::InterestingFile do

  it_behaves_like CMSScanner::Finders::Finding

  subject(:file) { described_class.new(url) }
  let(:url)      { 'http://example.com/' }

  describe '#==' do
    context 'when same URL' do
      it 'returns true' do
        expect(file == described_class.new(url)).to be true
      end
    end

    context 'when not the same URL' do
      it 'returns false' do
        expect(file == described_class.new('http://ex.lo')).to be false
      end
    end
  end

end
