require 'spec_helper'

describe 'SubScanner' do
  before :all do
    # Module including the CMSScanner to test its correct inclusion
    module SubScanner
      include CMSScanner

      # Override to make sure it can be overriden
      def self.app_name
        'subscanner'
      end

      VERSION = '1.0-Spec'
      APP_DIR = '/tmp/sub_scanner/spec'

      # This Target class should be called in the CMSScanner::Controller::Base
      # instead of the CMSScanner::Target
      class Target < CMSScanner::Target
        def new_method
          'working'
        end
      end

      # Testing the override of the register_options_files
      class Controllers < CMSScanner::Controllers
        def register_options_files
          option_parser.options_files << File.join(".#{SubScanner.app_name}", 'rspec.yml')
        end
      end

      # Custom method for all formatters
      module Formatter
        include CMSScanner::Formatter

        # Implements a #custom method which should be available in all formatters
        module InstanceMethods
          def custom
            'It Works!'
          end
        end
      end
    end

    CMSScanner::Controller::Base.reset
    CMSScanner::Browser.reset
  end

  after :all do
    CMSScanner.send(:remove_const, :NS)
    CMSScanner.const_set(:NS, CMSScanner)
    CMSScanner::Controller::Base.reset
  end

  subject(:scanner)     { SubScanner::Scan.new }
  let(:formatter_class) { SubScanner::Formatter }
  let(:target_url)      { 'http://ex.lo/' }

  before do
    scanner.controllers.first.class.parsed_options = { url: target_url }
  end

  describe '#app_name' do
    it 'returns the correct app_name' do
      expect(SubScanner.app_name).to eql 'subscanner'
    end
  end

  describe 'Browser#default_user_agent' do
    it 'returns the correct user_agent' do
      expect(SubScanner::Browser.instance.default_user_agent).to eql 'SubScanner v1.0-Spec'
    end
  end

  describe 'Controllers' do
    describe '#target' do
      it 'loads the overrided Target class' do
        target = scanner.controllers.first.target

        expect(target).to be_a SubScanner::Target
        expect(target).to respond_to(:new_method)
        expect(target.new_method).to eq 'working'
        expect(target.url).to eql target_url
      end
    end

    describe '#register_options_files' do
      let(:options_file_path) { '.subscanner/rspec.yml' }

      it 'register the correct file' do
        expect(File).to receive(:exist?).with(options_file_path).and_return(true)

        option_parser = SubScanner::Scan.new.controllers.option_parser

        expect(option_parser.options_files.map(&:path)).to eql [options_file_path]
      end
    end
  end

  describe 'Controller::Base#tmp_directory' do
    it 'returns the expected value' do
      expect(scanner.controllers.first.tmp_directory).to eql '/tmp/subscanner'
    end
  end

  describe 'Formatter' do
    it_behaves_like CMSScanner::Formatter::ClassMethods do
      subject(:formatter) { formatter_class }
    end

    describe '.load' do
      it 'adds the #custom method for all formatters' do
        formatter_class.availables.each do |format|
          expect(formatter_class.load(format).custom).to eql 'It Works!'
        end
      end
    end

    describe '#views_directories' do
      it 'returns the expected paths' do
        expect(scanner.formatter.views_directories).to eql(
          [
            CMSScanner::APP_DIR, SubScanner::APP_DIR,
            File.join(Dir.home, '.subscanner'), File.join(Dir.pwd, '.subscanner')
          ].reduce([]) do |a, e|
            a << File.join(e, 'views')
          end
        )
      end
    end
  end
end
