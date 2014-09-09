require 'spec_helper'

describe CMSScanner::Finders::InterestingFiles do

  it_behaves_like CMSScanner::Finders::IndependantFinder do
    let(:expected_finders) { %w(RobotsTxt) }
  end

  subject(:files) { described_class.new(target) }
  let(:target)    { CMSScanner::Target.new(url) }
  let(:url)       { 'http://example.com/' }

end
