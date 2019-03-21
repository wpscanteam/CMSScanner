# frozen_string_literal: true

describe CMSScanner::Finders::Finder do
  subject(:finder) { described_class.new('target') }

  describe '#create_progress_bar' do
    before { finder.create_progress_bar(opts) }

    context 'when opts[:show_progression] is true' do
      let(:opts) { { show_progression: true } }

      it 'uses the default progress-bar output' do
        expect(finder.progress_bar.send(:output)).to be_a ProgressBar::Outputs::Tty
      end
    end

    context 'when opts[:show_progression] is false' do
      let(:opts) { { show_progression: false } }

      it 'uses the null progress_bar outout' do
        expect(finder.progress_bar.send(:output)).to be_a ProgressBar::Outputs::Null
      end

      context 'when logging data' do
        context 'when no logs' do
          it 'returns an empty array' do
            expect(finder.progress_bar.log).to eql([])
          end
        end

        context 'when adding messages' do
          it 'returns the messages' do
            finder.progress_bar.log 'Hello'
            finder.progress_bar.log 'World'

            expect(finder.progress_bar.log).to eql(%w[Hello World])
          end
        end
      end
    end
  end

  its(:browser) { should be_a CMSScanner::Browser }

  its(:hydra) { should be_a Typhoeus::Hydra }

  describe '#found_by' do
    context 'when no klass supplied' do
      context 'when no passive or aggresive match' do
        it 'returns nil' do
          expect(finder).to receive(:caller_locations).and_return([])

          expect(finder.found_by).to be_nil
        end
      end

      # TODO: make the below work
      # context 'when aggressive match' do
      #  it 'returns the expected string' do
      #    expect(finder).to receive(:caller_locations)
      #      .and_return([Thread::Backtrace::Location.new("/aaaaa/file.rb:xx:in `aggressive'")])
      #
      #    expect(finder.found_by).to eql 'Finder (Aggressive Detection)'
      #  end
      # end
    end

    # context 'when class supplied' do
    #  it 'returns the expected string' do
    #    expect(finder).to receive(:caller_locations)
    #      .and_return(["/aaaaa/file.rb:xx:in `passive'"])
    #
    #    expect(finder.found_by('Rspec')).to eql 'Rspec (Passive Detection)'
    #  end
    # end
  end
end
