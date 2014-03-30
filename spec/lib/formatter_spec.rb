require 'spec_helper'

describe CMSScanner::Formatter do

  describe '#load' do
    context 'w/o parameter' do
      it 'loads the default formatter' do
        f = described_class.load

        f.should be_a described_class::Cli
      end
    end

    it 'loads the correct formatter' do
      f = described_class.load('cli_no_colour')

      f.should be_a described_class::CliNoColour
    end
  end

end

describe CMSScanner::Formatter::Base do

  subject(:formatter) { described_class.new }

  describe '#format' do
    its(:format) { should eq 'base' }
  end

  describe '#render, output' do
    before { formatter.views_directories << FIXTURES_VIEWS }

    it 'renders the global template and does not override the @views_directories' do
      $stdout.should_receive(:puts).with("It Works!\nViews Dirs: #{formatter.views_directories}")

      formatter.output('@test', test: 'Works!', views_directories: 'owned')
    end

    it 'raises an error if the controller_name is nil and tpl is not a global one' do
      expect { formatter.output('test') }.to raise_error('The controller_name can not be nil')
    end
  end

  describe '#view_path' do
    before do
      formatter.views_directories << FIXTURES_VIEWS
      formatter.render('local', {}, 'ctrl') # Used to set the @controller_name
    end

    context 'when the tpl format is invalid' do
      let(:tpl) { '../try-this' }

      it 'raises an error' do
        expect { formatter.view_path(tpl) }.to raise_error("Wrong tpl format: 'ctrl/#{tpl}'")
      end
    end

    context 'when the tpl is not found' do
      let(:tpl) { 'not_there' }

      it 'raises an error' do
        expect { formatter.view_path(tpl) }.to raise_error("View not found for base/ctrl/#{tpl}")
      end
    end

    context 'when the tpl is found' do
      context 'if it\'s a global tpl' do
        it 'returns its path' do
          expected = File.join(FIXTURES_VIEWS, 'base', 'test.erb')

          formatter.view_path('@test').should eq expected
        end
      end

      context 'if it\s a local tpl' do
        it 'retuns its path' do
          expected = File.join(FIXTURES_VIEWS, 'base', 'ctrl', 'local.erb')

          formatter.view_path('local').should eq expected
        end
      end
    end
  end

  describe '#views_directories' do
    let(:default_directories) { [LIB_VIEWS, Pathname.new(Dir.pwd).join('views').to_s] }

    context 'when default directories' do
      its(:views_directories) { should eq(default_directories) }
    end

    context 'when adding directories' do
      it 'adds them' do
        formatter.views_directories << 'testing'

        formatter.views_directories.should eq(default_directories << 'testing')
      end
    end
  end

end
