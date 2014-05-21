require 'spec_helper'

describe CMSScanner::Controller do

  subject(:controller) { described_class::Base.new }

  context 'when parsed_options' do
    before               { described_class::Base.parsed_options = parsed_options }
    let(:parsed_options) { { url: 'http://example.com/' } }

    its(:parsed_options) { should eq(parsed_options) }
    its(:formatter)      { should be_a CMSScanner::Formatter::Cli }
    its(:target)         { should be_a CMSScanner::Target }

    describe '#render' do
      it 'calls the formatter#render' do
        controller.formatter.should_receive(:render).with('test', { verbose: nil }, 'base')
        controller.render('test')
      end
    end
  end

end
