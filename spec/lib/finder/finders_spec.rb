require 'spec_helper'

describe CMSScanner::Finder::Finders do

  subject(:finders) { described_class.new }

  describe '#symbols_from_mode' do
    after { expect(finders.symbols_from_mode(@mode)).to eq @expected }

    context 'when :mixed' do
      it 'returns [:passive, :aggressive]' do
        @mode     = :mixed
        @expected = [:passive, :aggressive]
      end
    end

    context 'when :passive or :aggresssive' do
      [:passive, :aggressive].each do |symbol|
        it 'returns it in an array' do
          @mode     = symbol
          @expected = [*symbol]
        end
      end
    end

    context 'otherwise' do
      it 'returns []' do
        @mode     = :unallowed
        @expected = []
      end
    end
  end

  describe '#findings' do
    it 'returns a Findings object' do
      expect(finders.findings).to be_a CMSScanner::Finder::Findings
    end
  end

end
