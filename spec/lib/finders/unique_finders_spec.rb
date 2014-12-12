require 'spec_helper'
require 'dummy_unique_finders'

describe CMSScanner::Finders::UniqueFinders do
  subject(:finders) { described_class.new }

  let(:finding)     { CMSScanner::DummyFinding }
  let(:opts)        { {} }

  describe '#run' do
    let(:target) { 'target' }

    before do
      finders <<
        CMSScanner::Finders::Unique::Dummy.new(target) <<
        CMSScanner::Finders::Unique::NoAggressive.new(target) <<
        CMSScanner::Finders::Unique::Dummy2.new(target)
    end

    describe 'calls order' do
      after { finders.run(opts) }

      context 'when :check_all' do
        [:passive, :aggressive].each do |current_mode|
          context "when #{current_mode} mode" do
            let(:opts) { super().merge(mode: current_mode) }

            it "calls the #{current_mode} method on all finders" do
              finders.each { |f| expect(f).to receive(current_mode).ordered }
            end
          end
        end

        context 'when :mixed mode' do
          let(:opts) { super().merge(mode: :mixed) }

          it '' do
            [:passive, :aggressive].each do |method|
              finders.each do |finder|
                expect(finder).to receive(method).ordered
              end
            end
          end
        end
      end
    end

    describe 'returned result' do
      after do
        result = finders.run(opts)

        expect(result).to be_a finding
        expect(result).to eql @expected
      end

      context 'when :check_all' do
        let(:opts) { { check_all: true } }

        context 'when :mixed mode' do
          let(:opts) { super().merge(mode: :mixed) }

          it 'returns the expected result' do
            @expected = finding.new('test', confidence: 100, found_by: 'Dummy (passive detection)')
            @expected.confirmed_by << finding.new('test', confidence: 100, found_by: 'override')
          end
        end
      end

      context 'when no :check_all' do
        # TODO
      end
    end
  end
end
