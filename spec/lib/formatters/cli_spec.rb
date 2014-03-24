require 'spec_helper'

describe CMSScanner::Formatter::Cli do

  subject(:formatter) { described_class.new }

  describe '#format' do
    its(:format) { should eq 'cli' }
  end

  describe '#green, #red, #colorize' do
    it 'returns the correct red string' do
      formatter.red('Text').should eq("\e[31mText\e[0m")
    end

    it 'returns the correct green string' do
      formatter.green('Another Text').should eq("\e[32mAnother Text\e[0m")
    end
  end

end
