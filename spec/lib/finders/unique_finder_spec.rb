require 'spec_helper'

module CMSScanner
  module Finders
    # Dummy Class to test the module
    class VersionFinderSpec
      include UniqueFinder

      def initialize(_target)
      end
    end
  end
end

describe CMSScanner::Finders::VersionFinderSpec do
  it_behaves_like CMSScanner::Finders::IndependentFinder do
    let(:expected_finders) { [] }
    let(:expected_finders_class) { CMSScanner::Finders::UniqueFinders }
  end

  subject(:files) { described_class.new(target) }
  let(:target)    { CMSScanner::Target.new(url) }
  let(:url)       { 'http://example.com/' }
end
