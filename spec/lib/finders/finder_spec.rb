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

  describe '#found_by' do
    context 'when no passive or aggresive match' do
      it 'returns nil' do
        expect(finder).to receive(:caller_locations).and_return([])

        expect(finder.found_by).to be_nil
      end
    end
  end
end
