require 'spec_helper'
require 'dummy_finders'

describe CMSScanner::Finders::Findings do

  subject(:findings) { described_class.new }
  let(:dummy)        { CMSScanner::DummyFinding }

  describe '#<<' do
    after { expect(findings).to eq @expected }

    context 'when empty array' do
      it 'adds it' do
        findings << 'empty-test'
        @expected = %w(empty-test)
      end
    end

    context 'when not empty' do
      let(:confirmed) { dummy.new('confirmed') }

      before { findings << dummy.new('test') << confirmed }

      it 'adds a confirmed result correctly' do
        confirmed_dup = confirmed.dup
        confirmed_dup.confidence = 100

        findings << dummy.new('test2')
        findings << confirmed_dup

        confirmed.confirmed_by = confirmed_dup

        @expected = [] << dummy.new('test') << confirmed << dummy.new('test2')
      end
    end
  end

end
