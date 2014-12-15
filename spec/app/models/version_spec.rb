require 'spec_helper'

describe CMSScanner::Version do
  it_behaves_like CMSScanner::Finders::Finding

  subject(:version) { described_class.new(number, opts) }
  let(:opts)        { {} }
  let(:number)      { '1.0' }

  describe '#==' do
    context 'when same @number' do
      it 'returns true' do
        expect(version == described_class.new(number)).to be true
      end
    end

    context 'when not the same @number' do
      it 'returns false' do
        expect(version == described_class.new('3.0')).to be false
      end
    end
  end
end
