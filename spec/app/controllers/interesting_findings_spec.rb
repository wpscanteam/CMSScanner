require 'spec_helper'

describe CMSScanner::Controller::InterestingFindings do
  subject(:controller) { described_class.new }
  let(:target_url)     { 'http://example.com/' }
  let(:cli_args)       { "--url #{target_url}" }
  let(:parsed_options) { rspec_parsed_options(cli_args) }

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
      expect(controller.cli_options.map(&:to_sym)).to eq [:interesting_findings_detection]
    end
  end

  describe '#run' do
    before do
      expect(controller.target).to receive(:interesting_findings)
        .with(
          mode: parsed_options[:interesting_findings_detection] || parsed_options[:detection_mode]
        ).and_return(stubbed)
    end

    after { controller.run }

    %i[mixed passive aggressive].each do |mode|
      context "when --detection-mode #{mode}" do
        let(:cli_args) { "#{super()} --detection-mode #{mode}" }

        context 'when no findings' do
          let(:stubbed) { [] }

          before { expect(controller.formatter).to_not receive(:output) }

          it 'does not call the formatter' do
            # Handled by the before statements above
          end

          context 'when --interesting-files-detection mode supplied' do
            let(:cli_args) { "#{super()} --interesting-findings-detection passive" }

            it 'gives the correct detection paramter' do
              # Handled by before/after statements
            end
          end
        end

        context 'when findings' do
          let(:stubbed) { ['yolo'] }

          it 'calls the formatter with the correct parameter' do
            expect(controller.formatter).to receive(:output)
              .with('findings', hash_including(findings: stubbed), 'interesting_findings')
          end
        end
      end
    end
  end
end
