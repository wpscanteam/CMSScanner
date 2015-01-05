require 'spec_helper'
require 'dummy_unique_finders'

describe CMSScanner::Finders::UniqueFinders do
  subject(:finders) { described_class.new }

  describe '#run' do
    let(:target)         { 'target' }
    let(:finding)        { CMSScanner::DummyFinding }
    let(:unique_finders) { CMSScanner::Finders::Unique }
    let(:opts)           { {} }

    before do
      finders <<
        unique_finders::Dummy.new(target) <<
        unique_finders::NoAggressive.new(target) <<
        unique_finders::Dummy2.new(target)
    end

    after do
      result = finders.run(opts)

      expect(result).to be_a finding
      expect(result).to eql @expected
    end

    # Used to be able to test the calls order and returned result at the same time
    let(:dummy_passive)     { unique_finders::Dummy.new(target).passive(opts) }
    let(:dummy_aggresssive) { unique_finders::Dummy.new(target).aggressive(opts) }
    let(:noaggressive)      { unique_finders::NoAggressive.new(target).passive(opts) }
    let(:dummy2_aggressive) { unique_finders::Dummy2.new(target).aggressive }

    context 'when :confidence_threshold <= 0' do
      let(:opts) { super().merge(confidence_threshold: 0) }

      context 'when :mixed mode' do
        let(:opts) { super().merge(mode: :mixed) }

        it 'calls all #passive then #aggressive on finders and returns the best result' do
          # Maybe there is a way to factorise this
          expect(finders[0]).to receive(:passive).ordered.and_return(dummy_passive)
          expect(finders[1]).to receive(:passive).ordered.and_return(noaggressive)
          expect(finders[2]).to receive(:passive).ordered
          expect(finders[0]).to receive(:aggressive).ordered.and_return(dummy_aggresssive)
          expect(finders[1]).to receive(:aggressive).ordered
          expect(finders[2]).to receive(:aggressive).ordered.and_return(dummy2_aggressive)

          @expected = finding.new('v1', confidence: 100, found_by: 'Dummy (Passive Detection)')
          @expected.confirmed_by << finding.new('v1', confidence: 100, found_by: 'override')
          @expected.confirmed_by << finding.new('v1', confidence: 90)
        end
      end

      context 'when :passive mode' do
        let(:opts) { super().merge(mode: :passive) }

        it 'calls #passive on all finders and returns the best result' do
          expect(finders[0]).to receive(:passive).ordered.and_return(dummy_passive)
          expect(finders[1]).to receive(:passive).ordered.and_return(noaggressive)
          expect(finders[2]).to receive(:passive).ordered

          finders.each { |f| expect(f).to_not receive(:aggressive) }

          @expected = finding.new('v2', confidence: 10,
                                        found_by: 'No Aggressive (Passive Detection)')
        end
      end

      context 'when :aggressive mode' do
        let(:opts) { super().merge(mode: :aggressive) }

        it 'calls #aggressive on all finders and returns the best result' do
          finders.each { |f| expect(f).to_not receive(:passive) }

          expect(finders[0]).to receive(:aggressive).ordered.and_return(dummy_aggresssive)
          expect(finders[1]).to receive(:aggressive).ordered
          expect(finders[2]).to receive(:aggressive).ordered.and_return(dummy2_aggressive)

          @expected = finding.new('v1', confidence: 100, found_by: 'override')
          @expected.confirmed_by << finding.new('v1', confidence: 90)
        end
      end
    end

    context 'when :confidence_threshold = 100 (default)' do
      context 'when :mixed mode' do
        let(:opts) { super().merge(mode: :mixed) }

        it 'calls all #passive then #aggressive methods on finders and returns the '\
           'result which reaches 100% confidence during the process' do
          expect(finders[0]).to receive(:passive).ordered.and_return(dummy_passive)
          expect(finders[1]).to receive(:passive).ordered.and_return(noaggressive)
          expect(finders[2]).to receive(:passive).ordered
          expect(finders[0]).to receive(:aggressive).ordered.and_return(dummy_aggresssive)
          expect(finders[1]).to_not receive(:aggressive)
          expect(finders[2]).to_not receive(:aggressive)

          @expected = finding.new('v1', confidence: 100, found_by: 'Dummy (Passive Detection)')
          @expected.confirmed_by << finding.new('v1', confidence: 100, found_by: 'override')
        end
      end

      context 'when :passive mode' do
        let(:opts) { super().merge(mode: :passive) }

        it 'calls all #passive and returns the best result' do
          expect(finders[0]).to receive(:passive).ordered.and_return(dummy_passive)
          expect(finders[1]).to receive(:passive).ordered.and_return(noaggressive)
          expect(finders[2]).to receive(:passive).ordered

          finders.each { |f| expect(f).to_not receive(:aggressive) }

          @expected = finding.new('v2', confidence: 10,
                                        found_by: 'No Aggressive (Passive Detection)')
        end
      end

      context 'when :aggressive mode' do
        let(:opts) { super().merge(mode: :aggressive) }

        it 'calls all #aggressive and returns the result which reaches 100% confidence' do
          finders.each { |f| expect(f).to_not receive(:passive) }

          expect(finders[0]).to receive(:aggressive).ordered.and_return(dummy_aggresssive)
          expect(finders[1]).to_not receive(:aggressive)
          expect(finders[2]).to_not receive(:aggressive)

          @expected = finding.new('v1', confidence: 100, found_by: 'override')
        end
      end
    end
  end
end
