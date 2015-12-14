require 'spec_helper'

describe CMSScanner::MockedProgressBar do
  subject(:bar) { described_class.create }

  [:finish, :increment, :log, :total, :total=].each do |method|
    describe "#{method}" do
      it { should respond_to(:method) }
    end
  end

  describe '#total' do
    it 'returns an integer' do
      expect(bar.total).to be_a Integer
    end
  end

  describe '#log' do
    it 'adds messages when supplied' do
      bar.log('L1')
      bar.log('L2')

      expect(bar.log).to eql %w(L1 L2)
    end
  end
end
