require 'spec_helper'

describe CMSScanner::Finders::Finder do
  subject(:finder) { described_class.new('target') }

  describe '#progress_bar' do
    it 'returns a ProgressBar::Base' do
      expect(finder.progress_bar(total: 12)).to be_a ProgressBar::Base
    end
  end

  its(:browser) { should be_a CMSScanner::Browser }

  its(:hydra) { should be_a Typhoeus::Hydra }
end
