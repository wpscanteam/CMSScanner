require 'spec_helper'

describe CMSScanner::Version do
  it_behaves_like CMSScanner::Finders::Finding

  subject(:version) { described_class.new(number, opts) }
  let(:opts)        { {} }
  let(:number)      { '1.0' }

  describe '#number' do
    its(:number) { should eql '1.0' }

    context 'when float number supplied' do
      let(:number) { 2.0 }

      its(:number) { should eq '2.0' }
    end
  end

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
