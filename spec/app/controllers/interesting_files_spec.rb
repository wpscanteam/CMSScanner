require 'spec_helper'

describe CMSScanner::Controller::InterestingFiles do

  subject(:controller) { described_class.new }
  let(:target_url)     { 'http://example.com/' }
  let(:parsed_options) { { url: target_url } }

  before do
    CMSScanner::Browser.reset
    described_class.parsed_options = parsed_options
  end

  its(:cli_options) { should be_nil }
  its(:before_scan) { should be_nil }
  its(:after_scan)  { should be_nil }

  describe '#run' do
    before { expect(controller.target).to receive(:interesting_files).and_return(stubbed) }
    after  { controller.run }

    context 'when no findings' do
      let(:stubbed) { [] }

      it 'does not call the formatter' do
        expect(controller.formatter).to_not receive(:output)
      end
    end

    # TODO: Test the output with a dummy finding ?
    context 'when findings' do
      let(:stubbed) { ['yolo'] }

      it 'calls the formatter with the correct parameter' do
        expect(controller.formatter).to receive(:output)
          .with('findings', hash_including(findings: stubbed), 'interesting_files')
      end
    end
  end

end
