require 'spec_helper'

describe CMSScanner::Finders::Finder::Enumerator do
  # Dummy class to test the module
  class DummyEnumeratorFinder < CMSScanner::Finders::Finder
    include CMSScanner::Finders::Finder::Enumerator
  end

  subject(:finder) { DummyEnumeratorFinder.new(target) }
  let(:target)     { CMSScanner::Target.new('http://e.org') }

  its(:request_params) { should eql(cache_ttl: 0) }

  describe '#enumerate' do
    before do
      target_urls.each_key { |url| stub_request(:get, url).to_return(status: 200, body: 'rspec') }
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
          expect { |b| finder.enumerate(target_urls, opts, &b) }.to_not yield_control
        end
      end

      context 'when not the hompage or 404' do
        before { expect(finder.target).to receive(:homepage_or_404?).twice }

        it 'yield the expected items' do
          expect { |b| finder.enumerate(target_urls, opts, &b) }.to yield_successive_args(
            [Typhoeus::Response, 1], [Typhoeus::Response, 2]
          )
        end
      end
    end

    context 'when opts' do
      context 'when :exclude_content' do
        before { expect(finder.target).to receive(:homepage_or_404?).twice }

        context 'when body matches' do
          let(:opts) { { exclude_content: /spec/i } }

          it 'does not yield anything' do
            expect { |b| finder.enumerate(target_urls, opts, &b) }.to_not yield_control
          end
        end

        context 'when body does not match' do
          let(:opts) { { exclude_content: /not/i } }

          it 'yield the expected items' do
            expect { |b| finder.enumerate(target_urls, opts, &b) }.to yield_successive_args(
              [Typhoeus::Response, 1], [Typhoeus::Response, 2]
            )
          end
        end

        context 'when header matches' do
          let(:opts) { { exclude_content: %r{Location: /aa}i } }

          before do
            target_urls.each_key do |url|
              stub_request(:get, url).to_return(status: 301,
                                                headers: { 'Location' => '/aa' })
            end
          end

          it 'does not yield anything' do
            expect { |b| finder.enumerate(target_urls, opts, &b) }.to_not yield_control
          end
        end

        context 'when header does not match' do
          let(:opts) { { exclude_content: /not 301/i } }

          it 'yield the expected items' do
            expect { |b| finder.enumerate(target_urls, opts, &b) }.to yield_successive_args(
              [Typhoeus::Response, 1], [Typhoeus::Response, 2]
            )
          end
        end
      end
    end
  end
end
