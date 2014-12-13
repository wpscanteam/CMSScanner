require 'spec_helper'

describe CMSScanner::Formatter::Cli do
  subject(:formatter) { described_class.new }

  describe '#format' do
    its(:format) { should eq 'cli' }
  end

  describe '#green, #red, #colorize' do
    it 'returns the correct red string' do
      expect(formatter.red('Text')).to eq "\e[31mText\e[0m"
    end

    it 'returns the correct green string' do
      expect(formatter.green('Another Text')).to eq "\e[32mAnother Text\e[0m"
    end
  end
end
