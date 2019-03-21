# frozen_string_literal: true

module CMSScanner
  module Finders
    # Dummy Class to test the module
    class PluginsFinderSpec
      include SameTypeFinder

      def initialize(_target); end
    end
  end
end

describe CMSScanner::Finders::PluginsFinderSpec do
  it_behaves_like CMSScanner::Finders::IndependentFinder do
    let(:expected_finders) { [] }
    let(:expected_finders_class) { CMSScanner::Finders::SameTypeFinders }
  end

  subject(:plugins) { described_class.new(target) }
  let(:target)      { CMSScanner::Target.new(url) }
  let(:url)         { 'http://example.com/' }
end
