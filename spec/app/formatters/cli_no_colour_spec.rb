require 'spec_helper'

describe CMSScanner::Formatter::CliNoColour do
  subject(:formatter) { described_class.new }

  describe '#format' do
    its(:format) { should eq 'cli' }
  end

  describe '#colorize' do
    it 'returns the text w/o any colour' do
      expect(formatter.red('Text')).to eq 'Text'
    end
  end
end
