require 'spec_helper'

describe CMSScanner::Finders::InterestingFiles do
  it_behaves_like CMSScanner::Finders::IndependentFinder do
    let(:expected_finders) { %w(Headers RobotsTxt FantasticoFileslist SearchReplaceDB2 XMLRPC) }
    let(:expected_finders_class) { CMSScanner::Finders::IndependentFinders }
  end

  subject(:files) { described_class.new(target) }
  let(:target)    { CMSScanner::Target.new(url) }
  let(:url)       { 'http://example.com/' }
end
