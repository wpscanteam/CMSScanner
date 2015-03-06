require 'spec_helper'

describe CMSScanner::Finders::Finder::Enumerator do
  # Dummy class to test the module
  class DummyFinder < CMSScanner::Finders::Finder
    include CMSScanner::Finders::Finder::Enumerator
  end

  subject(:finder) { DummyFinder.new(target) }
  let(:target)     { CMSScanner::Target.new('http://e.org') }

  context 'when #target_urls not implemented' do
    it 'raises errors' do
      expect { finder.target_urls }.to raise_error NotImplementedError
    end
  end

  its(:browser) { should be_a CMSScanner::Browser }

  its(:request_params) { should eql(cache_ttl: 0) }

  its(:hydra) { should be_a Typhoeus::Hydra }

  describe '#enumerate' do
    before do
      expect(finder).to receive(:target_urls).and_return(target_urls)
      target_urls.each { |url, _| stub_request(:get, url).to_return(status: 200, body: 'rspec') }
    end

    let(:target_urls) do
      {
        target.url('1') => 1,
        target.url('2') => 2
      }
    end

    context 'when no opts' do
      let(:opts) { {} }

      context 'when response are the homepage or custom 404' do
        before { expect(finder.target).to receive(:homepage_or_404?).twice.and_return(true) }

        it 'does not yield anything' do
          expect { |b| finder.enumerate(opts, &b) }.to_not yield_control
        end
      end

      context 'when not the hompage or 404' do
        before { expect(finder.target).to receive(:homepage_or_404?).twice }

        it 'yield the expected items' do
          expect { |b| finder.enumerate(opts, &b) }.to yield_successive_args(
            [Typhoeus::Response, 1], [Typhoeus::Response, 2]
          )
        end
      end
    end

    context 'when opts' do
      context 'when :exclude_content' do
        before { expect(finder.target).to receive(:homepage_or_404?).twice }

        context 'when it matches' do
          let(:opts) { { exclude_content: /spec/i } }

          it 'does not yield anything' do
            expect { |b| finder.enumerate(opts, &b) }.to_not yield_control
          end
        end

        context 'when it does not match' do
          let(:opts) { { exclude_content: /not/i } }

          it 'yield the expected items' do
            expect { |b| finder.enumerate(opts, &b) }.to yield_successive_args(
              [Typhoeus::Response, 1], [Typhoeus::Response, 2]
            )
          end
        end
      end
    end
  end
end
