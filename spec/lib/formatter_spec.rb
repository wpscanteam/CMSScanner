require 'spec_helper'

describe CMSScanner::Formatter do

  describe '#load' do
    context 'w/o parameter' do
      it 'loads the default formatter' do
        f = described_class.load

        f.should be_a described_class::Cli
      end
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

    it 'renders the template and does not override the @views_directories' do
      $stdout.should_receive(:puts).with("It Works!\nViews Dirs: #{formatter.views_directories}")

      formatter.output('test', test: 'Works!', views_directories: 'owned')
    end
  end

  describe '#view_path' do
    context 'when the tpl format is invalid' do
      let(:tpl) { '../try-this' }

      it 'raises an error' do
        expect { formatter.view_path(tpl) }.to raise_error("Wrong tpl format: '#{tpl}'")
      end
    end

    context 'when the tpl is not found' do
      let(:tpl) { 'not_there' }

      it 'raises an error' do
        expect { formatter.view_path(tpl) }.to raise_error("View not found for base/#{tpl}")
      end
    end

    context 'when the tpl is found' do
      before { formatter.views_directories << FIXTURES_VIEWS }

      it 'returns its path' do
        tpl      = 'test'
        expected = File.join(FIXTURES_VIEWS, 'base', "#{tpl}.erb")

        formatter.view_path(tpl).should eq expected
      end
    end
  end

  describe '#views_directories' do
    let(:default_directories) { [Pathname.new(__FILE__).dirname.join('..', '..', 'lib', 'views').to_s, Pathname.new(Dir.pwd).join('views').to_s] }

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
