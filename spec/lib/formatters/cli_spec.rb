require 'spec_helper'

describe CMSScanner::Formatter::Cli do

  subject(:formatter) { described_class.new }

  describe '#format' do
    its(:format) { should eq 'cli' }
  end

end
