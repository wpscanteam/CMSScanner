require 'spec_helper'

describe CMSScanner::Formatter do

  describe '#load' do
    context 'w/o parameter' do
      it 'loads the default formatter' do
        expect(described_class.load).to be_a described_class::Cli
      end
    end

    it 'loads the correct formatter' do
      expect(described_class.load('cli_no_colour')).to be_a described_class::CliNoColour
    end

    it 'adds the custom_views' do
      formatter = described_class.load(nil, %w(/path/views1 /path2/views))

      expect(formatter.views_directories).to include('/path/views1', '/path2/views')
    end
  end

  describe '#availables' do
    it 'returns the right list' do
      expect(described_class.availables).to match_array(%w(json cli-no-colour cli))
    end
  end

end

module CMSScanner
  module Formatter
    module Spec
      # Base Format Test Class
      class BasedFormat < Base
        def base_format
          'base'
        end
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

    it 'renders the global template and does not override the @views_directories' do
      expect($stdout).to receive(:puts)
        .with("It Works!\nViews Dirs: #{formatter.views_directories}")

      formatter.output('@test', test: 'Works!', views_directories: 'owned')
    end

    context 'when global and local rendering are used inside a template' do
      it 'renders them correcly' do
        rendered = formatter.render('test', { var: 'Works' }, 'ctrl')

        expect(rendered).to eq "Test: Works\nLocal View\nGlobal View"
      end
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
      after { expect(formatter.view_path(@tpl)).to eq @expected }

      context 'if it\'s a global tpl' do
        it 'returns its path' do
          @expected = File.join(FIXTURES_VIEWS, 'base', 'test.erb')
          @tpl      = '@test'
        end
      end

      context 'if it\s a local tpl' do
        it 'retuns its path' do
          @expected = File.join(FIXTURES_VIEWS, 'base', 'ctrl', 'local.erb')
          @tpl      = 'local'
        end
      end
    end

    context 'when base_format' do
      subject(:formatter) { CMSScanner::Formatter::Spec::BasedFormat.new }

      after { expect(formatter.view_path(@tpl)).to eq @expected }

      context 'when the ovverided view exists' do
        it 'returns it' do
          @expected = File.join(FIXTURES_VIEWS, 'based_format', 'test.erb')
          @tpl      = '@test'
        end
      end

      it 'returns the base views otherwise' do
        @expected = File.join(FIXTURES_VIEWS, 'base', 'ctrl', 'local.erb')
        @tpl      = 'local'
      end
    end

  end

  describe '#views_directories' do
    let(:default_directories) { [APP_VIEWS] }

    context 'when default directories' do
      its(:views_directories) { should eq(default_directories) }
    end

    context 'when adding directories' do
      it 'adds them' do
        formatter.views_directories << 'testing'

        expect(formatter.views_directories).to eq(default_directories << 'testing')
      end
    end
  end

end
