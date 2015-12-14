require 'spec_helper'

describe CMSScanner::Finders::Finder do
  subject(:finder) { described_class.new('target') }

  describe '#create_progress_bar' do
    before { finder.create_progress_bar(opts) }

    context 'when opts[:show_progression] is true' do
      let(:opts) { { show_progression: true } }

      it 'sets #progress_bar to a ProgressBar::Base' do
        expect(finder.progress_bar).to be_a ProgressBar::Base
      end
    end

    context 'when opts[:show_progression] is false' do
      let(:opts) { { show_progression: false } }

      it 'sets #progress_bar to a MockedProgressBar' do
        expect(finder.progress_bar).to be_a CMSScanner::MockedProgressBar
      end
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
