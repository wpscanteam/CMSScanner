require 'spec_helper'

module CMSScanner
  module Controller
    # Failure class for testing
    class SpecFailure < Base
      def before_scan
        fail 'error spotted'
      end
    end
  end
end

describe CMSScanner do
  let(:target_url) { 'http://wp.lab/' }

  before do
    scanner = CMSScanner::Scan.new
    scanner.controllers.first.class.parsed_options = { url: target_url }
  end

  describe 'typhoeus_on_complete' do
    before { CMSScanner.total_requests = 0 }

    # TODO: find a way to test the cached requests which should not be counted
    it 'returns the expected number of requests' do
      stub_request(:get, /.*/)

      CMSScanner::Browser.get(target_url)

      expect(CMSScanner.total_requests).to eql 1
    end
  end
end

describe CMSScanner::Scan do
  subject(:scanner) { described_class.new }
  let(:controller)  { CMSScanner::Controller }

  describe '#new, #controllers' do
    its(:controllers) { should eq([controller::Core.new]) }
  end

  describe '#run' do
    it 'runs the controlllers and calls the formatter#beautify' do
      hydra = CMSScanner::Browser.instance.hydra

      expect(scanner.controllers).to receive(:run).ordered
      expect(hydra).to receive(:abort).ordered
      expect(scanner.formatter).to receive(:beautify).ordered

      scanner.run
    end

    context 'when an error is raised during the #run' do
      it 'aborts the scan with the associated output' do
        scanner.controllers[0] = controller::SpecFailure.new

        expect(scanner.formatter).to receive(:output)
          .with('@scan_aborted', hash_including(:reason, :trace, :verbose))

        scanner.run
      end
    end
  end

  describe '#datastore' do
    its(:datastore) { should eq({}) }
  end
end
