require 'spec_helper'

describe CMSScanner::Controller::InterestingFiles do
  subject(:controller) { described_class.new }
  let(:target_url)     { 'http://example.com/' }
  let(:parsed_options) { { url: target_url } }

  before do
    CMSScanner::Browser.reset
    described_class.parsed_options = parsed_options
  end

  its(:before_scan) { should be_nil }
  its(:after_scan)  { should be_nil }

  describe '#cli_options' do
    its(:cli_options) { should_not be_empty }
    its(:cli_options) { should be_a Array }

    it 'contains to correct options' do
      expect(controller.cli_options.map(&:to_sym)).to eq [:interesting_files_detection]
    end
  end

  describe '#run' do
    before do
      expect(controller.target).to receive(:interesting_files)
        .with(
          mode: parsed_options[:interesting_files_detection] || parsed_options[:detection_mode]
        ).and_return(stubbed)
    end

    after { controller.run }

    [:mixed, :passive, :aggressive].each do |mode|
      context "when --detection-mode #{mode}" do
        let(:parsed_options) { super().merge(detection_mode: mode) }

        context 'when no findings' do
          let(:stubbed) { [] }

          before { expect(controller.formatter).to_not receive(:output) }

          it 'does not call the formatter' do
            # Handled by the before statements above
          end

          context 'when --interesting-files-detection mode supplied' do
            let(:parsed_options) do
              super().merge(interesting_files_detection: :passive)
            end

            it 'gives the correct detection paramter' do
              # Handled by before/after statements
            end
          end
        end

        context 'when findings' do
          let(:stubbed) { ['yolo'] }

          it 'calls the formatter with the correct parameter' do
            expect(controller.formatter).to receive(:output)
              .with('findings', hash_including(findings: stubbed), 'interesting_files')
          end
        end
      end
    end
  end
end
