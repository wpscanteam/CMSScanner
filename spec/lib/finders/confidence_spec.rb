require 'spec_helper'

describe CMSScanner::Finders::Confidence do
  subject(:confidence) { described_class.new(number) }

  describe '#new' do
    let(:number) { 10 }

    its(:value) { should eq 10 }
  end

  describe '#+' do
    context 'when the confidence is already at 100' do
      let(:number) { 100 }

      it 'returns 100' do
        expect(confidence + 50).to eq 100
      end
    end

    context 'when the confidence is below 100' do
      context 'when it reaches 100' do
        let(:number) { 90 }

        it 'returns 100' do
          expect(confidence + 50 + 80).to eq 100
        end
      end

      context 'when it satys below 100' do
        let(:number) { 50 }

        it 'returns the new value' do
          expect(confidence + 50).to eq 66
        end
      end
    end
  end
end
