require 'spec_helper'

describe CMSScanner::Formatter::Cli do

  subject(:formatter) { CMSScanner::Formatter::Cli.new }

  describe '#format' do
    its(:format) { should eq('cli') }
  end

end
