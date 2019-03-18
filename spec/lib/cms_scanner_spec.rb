describe CMSScanner do
  let(:target_url) { 'http://wp.lab/' }

  before do
    scanner = CMSScanner::Scan.new
    scanner.controllers.first.class.parsed_options = rspec_parsed_options("--url #{target_url}")
  end

  describe 'typhoeus_on_complete' do
    before do
      CMSScanner.cached_requests = 0
      CMSScanner.total_requests = 0
      CMSScanner.total_data_sent = 0
      CMSScanner.total_data_received = 0
    end

    it 'returns the expected number of requests' do
      stub_request(:get, /.*/).and_return(body: 'aa', headers: { 'key' => 'field' })

      CMSScanner::Browser.get(target_url)

      expect(CMSScanner.cached_requests).to eql 0
      expect(CMSScanner.total_requests).to eql 1
      expect(CMSScanner.total_data_sent).to eql 0 # can't really test this one it seems
      expect(CMSScanner.total_data_received).to eql 29
    end

    context 'when cached request' do
      it 'returns the expected values' do
        allow_any_instance_of(Typhoeus::Response).to receive(:cached?).and_return(true)

        stub_request(:get, target_url)

        CMSScanner::Browser.get(target_url)
        CMSScanner::Browser.get(target_url)

        expect(CMSScanner.cached_requests).to eql 2
        expect(CMSScanner.total_requests).to eql 0
        expect(CMSScanner.total_data_sent).to eql 0
        expect(CMSScanner.total_data_received).to eql 0
      end
    end
  end

  describe '#app_name' do
    it 'returns the excpected string' do
      expect(CMSScanner.app_name).to eql 'cms_scanner'
    end
  end
end

describe CMSScanner::Scan do
  subject(:scanner)    { described_class.new }
  let(:controller)     { CMSScanner::Controller }

  before do
    Object.send(:remove_const, :ARGV)
    Object.const_set(:ARGV, [])
  end

  describe '#new, #controllers' do
    its(:controllers) { should eq([controller::Core.new]) }
  end

  describe '#run' do
    after do
      scanner.run

      if defined?(run_error)
        expect(scanner.run_error).to be_a run_error.class
        expect(scanner.run_error.message).to eql run_error.message
      end
    end

    it 'runs the controlllers and calls the formatter#beautify' do
      # hydra = CMSScanner::Browser.instance.hydra

      expect(scanner.controllers).to receive(:run).ordered
      # expect(hydra).to receive(:abort).ordered
      expect(scanner.formatter).to receive(:beautify).ordered
    end

    context 'when no required option supplied' do
      it 'calls the formatter to display the usage view' do
        expect(scanner.formatter).to receive(:output)
          .with('@usage', msg: 'One of the following options is required: url, help, hh, version')
      end
    end

    context 'when an Interrupt is raised during the scan' do
      it 'aborts the scan with the correct output' do
        expect(scanner.controllers.option_parser).to receive(:results).and_return({})

        expect(scanner.controllers.first)
          .to receive(:before_scan)
          .and_raise(Interrupt)

        expect(scanner.formatter).to receive(:output)
          .with('@scan_aborted', hash_including(reason: 'Canceled by User', trace: anything, verbose: false))
      end
    end

    {
      NoMemoryError.new => true,
      ScriptError.new => true,
      SecurityError.new => true,
      SignalException.new('SIGTERM') => true,
      Interrupt.new('Canceled by User') => false,
      RuntimeError.new('error spotted') => true,
      CMSScanner::Error.new('aa') => false,
      CMSScanner::MaxScanDurationReachedError.new => false,
      SystemStackError.new => true
    }.each do |error, expected_verbose|
      context "when an/a #{error.class} is raised during the scan" do
        let(:run_error) { error }

        it 'aborts the scan with the associated output' do
          expect(scanner.controllers.option_parser).to receive(:results).and_return({})

          expect(scanner.controllers.first)
            .to receive(:before_scan)
            .and_raise(run_error.class, run_error.message)

          expect(scanner.formatter).to receive(:output)
            .with('@scan_aborted', hash_including(reason: run_error.message,
                                                  trace: anything,
                                                  verbose: expected_verbose))
        end
      end
    end
  end

  describe '#datastore' do
    its(:datastore) { should eq({}) }
  end

  describe '#exit_hook' do
    # No idea how to test that, maybe with another at_exit hook ? oO
    xit
  end
end
