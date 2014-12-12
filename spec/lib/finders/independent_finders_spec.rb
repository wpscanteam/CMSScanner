require 'spec_helper'
require 'dummy_independent_finders'

describe CMSScanner::Finders::IndependentFinders do
  subject(:finders) { described_class.new }

  describe '#run' do
    let(:target)              { 'target' }
    let(:finding)             { CMSScanner::DummyFinding }
    let(:expected_aggressive) { finding.new('test', found_by: 'override', confidence: 100) }
    let(:expected_passive) do
      [
        finding.new('test', found_by: 'DummyFinder (passive detection)'),
        finding.new('spotted', found_by: 'NoAggressiveResult (passive detection)', confidence: 10)
      ]
    end

    before do
      finders <<
        CMSScanner::Finders::Independent::DummyFinder.new(target) <<
        CMSScanner::Finders::Independent::NoAggressiveResult.new(target)
    end

    describe 'method calls order' do
      after { finders.run(mode: mode) }

      [:passive, :aggressive].each do |current_mode|
        context "when #{current_mode} mode" do
          let(:mode) { current_mode }

          it "calls the #{current_mode} method on each finder" do
            finders.each { |f| expect(f).to receive(current_mode).ordered }
          end
        end
      end

      context 'when :mixed mode' do
        let(:mode) { :mixed }

        it 'calls :passive then :aggressive on each finder' do
          finders.each do |finder|
            [:passive, :aggressive].each do |method|
              expect(finder).to receive(method).ordered
            end
          end
        end
      end
    end

    describe 'returned results' do
      before do
        @found = finders.run(mode: mode)

        expect(@found).to be_a(CMSScanner::Finders::Findings)

        @found.each { |f| expect(f).to be_a finding }
      end

      context 'when :passive mode' do
        let(:mode) { :passive }

        it 'returns 2 results' do
          expect(@found.size).to eq 2
          expect(@found.first).to eql expected_passive.first
          expect(@found.last).to eql expected_passive.last
        end
      end

      context 'when :aggressive mode' do
        let(:mode) { :aggressive }

        it 'returns 1 result' do
          expect(@found.size).to eq 1
          expect(@found.first).to eql expected_aggressive
        end
      end

      context 'when :mixed mode' do
        let(:mode) { :mixed }

        it 'returns 2 results' do
          # As the first passive is confirmed by the expected_aggressive, the confidence
          # increases and should be 100% due to the expected_aggressive.confidence
          first_passive = expected_passive.first.dup
          first_passive.confidence = 100

          expect(@found.size).to eq 2
          expect(@found.first).to eql first_passive
          expect(@found.first.confirmed_by).to eql [expected_aggressive]
          expect(@found.last).to eql expected_passive.last
        end
      end

      context 'when multiple results returned' do
        xit
      end
    end
  end

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
      expect(finders.findings).to be_a CMSScanner::Finders::Findings
    end
  end
end
