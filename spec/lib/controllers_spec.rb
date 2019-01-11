module CMSScanner
  module Controller
    class Spec < Base
    end

    class SpecTooLong < Spec
      def run
        sleep(2)
      end
    end
  end
end

describe CMSScanner::Controllers do
  subject(:controllers)  { described_class.new }
  let(:controller_mod) { CMSScanner::Controller }

  describe '#<<' do
    its(:size) { should be 0 }

    context 'when controllers are added' do
      before { controllers << controller_mod::Spec.new << controller_mod::Base.new }

      its(:size) { should be 2 }
    end

    context 'when a controller is added twice' do
      before { 2.times { controllers << controller_mod::Spec.new } }

      its(:size) { should be 1 }
    end

    it 'returns self' do
      expect(controllers << controller_mod::Spec.new).to be_a described_class
    end
  end

  describe '#run' do
    it 'runs the before_scan, run and after_scan methods of each controller' do
      spec = controller_mod::Spec.new
      base = controller_mod::Base.new

      controllers << base << spec

      # Needed otherwise the default_argv is taken from rspec
      # (@default_argv=["--pattern", "spec/**{,/*/**}/*_spec.rb"]>)
      expect(controllers.option_parser).to receive(:results).and_return({})

      [base, spec].each { |c| expect(c).to receive(:before_scan).ordered }
      [base, spec].each { |c| expect(c).to receive(:run).ordered }
      [spec, base].each { |c| expect(c).to receive(:after_scan).ordered }

      controllers.run
    end

    context 'when max_scan_duration is provided' do
      before do
        expect(controllers.option_parser).to receive(:results)
          .and_return(max_scan_duration: max_scan_duration)

        controllers << controller_mod::Spec.new << controller_mod::SpecTooLong.new
      end

      context 'when the scan exceeds the max duration' do
        let(:max_scan_duration) { 1 }

        it 'raises an exception' do
          expect { controllers.run }.to raise_error(CMSScanner::MaxScanDurationReachedError)
        end
      end

      context 'when the scan does not exceed to max duration' do
        let(:max_scan_duration) { 4 }

        it 'does not raise an exception' do
          expect { controllers.run }.to_not raise_error
        end
      end
    end
  end

  describe '#register_options_files' do
    it 'register the correct files' do
      expect(File).to receive(:exist?).exactly(4).times.and_return(true)

      expected = []
      option_parser = controllers.option_parser

      [Dir.home, Dir.pwd].each do |dir|
        option_parser.options_files.supported_extensions.each do |ext|
          expected << File.join(dir, '.cms_scanner', "cli_options.#{ext}")
        end
      end

      expect(option_parser.options_files.map(&:path)).to eql expected
    end
  end
end
