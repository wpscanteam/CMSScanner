require 'spec_helper'

describe CMSScanner::Scan do

  subject(:scanner) { described_class.new }

  describe '#new, #controllers' do
    its(:controllers) { should eq([CMSScanner::Controller::Core.new]) }
  end

  describe '#run' do
    it 'runs the controlllers and calls the formatter#beautify' do
      expect(scanner.controllers).to receive(:run)
      expect(scanner.formatter).to receive(:beautify)
      scanner.run
    end

    context 'when an error is raised during the #run' do
      module CMSScanner
        module Controller
          # Failure class for testing
          class Failure < Base
            def before_scan
              fail 'error spotted'
            end
          end
        end
      end

      it 'aborts the scan with the associated output' do
        scanner.controllers[0] = CMSScanner::Controller::Failure.new

        expect(scanner.formatter).to receive(:output)
          .with('@scan_aborted', hash_including(:reason, :trace, :verbose))

        scanner.run
      end
    end
  end
end
