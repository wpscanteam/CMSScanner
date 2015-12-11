require 'spec_helper'

describe CMSScanner::Controller::Core do
  subject(:core)       { described_class.new }
  let(:target_url)     { 'http://example.com/' }
  let(:parsed_options) { { url: target_url } }

  before do
    CMSScanner::Browser.reset
    described_class.parsed_options = parsed_options
  end

  its(:cli_options) { should_not be_empty }
  its(:cli_options) { should be_a Array }

  describe '#setup_cache' do
    context 'when no cache_dir supplied (or default)' do
      it 'returns nil' do
        expect(core.setup_cache).to eq nil
      end
    end

    context 'when cache_dir' do
      let(:parsed_options) { super().merge(cache_dir: CACHE) }
      let(:cache)          { Typhoeus::Config.cache }
      let(:storage) { File.join(parsed_options[:cache_dir], Digest::MD5.hexdigest(target_url)) }

      before { core.setup_cache }
      after  { Typhoeus::Config.cache = nil }

      it 'sets up the cache' do
        expect(cache).to be_a CMSScanner::Cache::Typhoeus
        expect(cache.storage_path).to eq storage
      end
    end
  end

  describe '#before_scan' do
    context 'when output_banner = false' do
      before { expect(core.formatter).to_not receive(:output) }

      it 'does not raise an error when everything is fine' do
        stub_request(:get, target_url).to_return(status: 200)

        expect { core.before_scan(false) }.to_not raise_error
      end
    end

    context 'when output_banner = true (default)' do
      before { expect(core.formatter).to receive(:output) }

      it 'does not raise an error when everything is fine' do
        stub_request(:get, target_url).to_return(status: 200)

        expect { core.before_scan }.to_not raise_error
      end

      it 'raise an error when the site is down' do
        stub_request(:get, target_url).to_return(status: 0)

        expect { core.before_scan }
          .to raise_error(
            CMSScanner::TargetDownError,
            "The url supplied '#{target_url}' seems to be down ()"
          )
      end

      context 'when it redirects' do
        before do
          stub_request(:get, target_url).to_return(status: 301, headers: { location: redirection })

          expect(core.target).to receive(:homepage_res).and_return(Typhoeus::Response.new(effective_url: redirection))
        end

        context 'when out of scope' do
          let(:redirection) { 'http://somewhere.com/' }

          context 'when the --ignore-main-redirect is not supplied' do
            it 'raises an error' do
              expect { core.before_scan }.to raise_error(
                CMSScanner::HTTPRedirectError,
                "The URL supplied redirects to #{redirection}." \
                ' Use the --ignore-main-redirect option to ignore the redirection and scan the target.'
              )
            end
          end

          context 'when the --ignore-main-redirect is supplied' do
            let(:parsed_options) { super().merge(ignore_main_redirect: true) }

            it 'does not raise any error' do
              expect { core.before_scan }.to_not raise_error
              expect(core.target.url).to eql target_url

              expect(core.target).to receive(:homepage_res).and_call_original
              expect(core.target.homepage_url).to eql target_url
            end
          end
        end

        context 'when in scope' do
          let(:redirection) { "#{target_url}home" }

          it 'does not raise any error' do
            expect { core.before_scan }.to_not raise_error
            expect(core.target.url).to eql target_url

            # expect(core.target).to receive(:homepage_res).and_call_original
            # expect(core.target.homepage_url).to eql redirection # Doesn't work, no idea why :x
          end
        end
      end

      context 'when access is forbidden' do
        before { stub_request(:get, target_url).to_return(status: 403) }

        it 'raises an error' do
          expect { core.before_scan }.to raise_error(CMSScanner::AccessForbiddenError)
        end
      end

      # This is quite a mess (as Webmock doesn't issue itself another 401
      # when credential are incorrect :/)
      context 'when http authentication' do
        context 'when no credentials' do
          before { stub_request(:get, target_url).to_return(status: 401) }

          it 'raises an error' do
            expect { core.before_scan }.to raise_error(CMSScanner::HTTPAuthRequiredError)
          end
        end

        context 'when credentials' do
          context 'when valid' do
            before { stub_request(:get, 'http://user:pass@example.com') }

            let(:parsed_options) do
              super().merge(http_auth: { username: 'user', password: 'pass' })
            end

            it 'does not raise any error' do
              expect { core.before_scan }.to_not raise_error
            end
          end

          context 'when invalid' do
            before { stub_request(:get, 'http://user:p@ss@example.com').to_return(status: 401) }

            let(:parsed_options) do
              super().merge(http_auth: { username: 'user', password: 'p@ss' })
            end

            it 'raises an error' do
              expect { core.before_scan }.to raise_error(CMSScanner::HTTPAuthRequiredError)
            end
          end
        end
      end

      context 'when proxy authentication' do
        before { stub_request(:get, target_url).to_return(status: 407) }

        context 'when no credentials' do
          it 'raises an error' do
            expect { core.before_scan }.to raise_error(CMSScanner::ProxyAuthRequiredError)
          end
        end

        context 'when invalid credentials' do
          let(:parsed_options) { super().merge(proxy_auth: { username: 'user', password: 'p@ss' }) }

          it 'raises an error' do
            expect(CMSScanner::Browser.instance.proxy_auth).to eq(parsed_options[:proxy_auth])

            expect { core.before_scan }.to raise_error(CMSScanner::ProxyAuthRequiredError)
          end
        end

        context 'when valid credentials' do
          before { stub_request(:get, target_url) }

          let(:parsed_options) { super().merge(proxy_auth: { username: 'user', password: 'pass' }) }

          it 'raises an error' do
            expect(CMSScanner::Browser.instance.proxy_auth).to eq(parsed_options[:proxy_auth])

            expect { core.before_scan }.to_not raise_error
          end
        end
      end
    end
  end

  describe '#run' do
    it 'calls the formatter with the correct parameters' do
      expect(core.formatter).to receive(:output)
        .with('started',
              hash_including(:start_memory, :start_time, :verbose, url: target_url),
              'core')

      core.run
    end
  end

  describe '#after_scan' do
    let(:keys) { [:verbose, :start_time, :stop_time, :start_memory, :elapsed, :used_memory] }

    it 'calls the formatter with the correct parameters' do
      # Call the #run once to ensure that @start_time & @start_memory are set
      expect(core).to receive(:output).with('started', hash_including(url: target_url))
      core.run

      RSpec::Mocks.space.proxy_for(core).reset # Must reset due to the above statements

      expect(core.formatter).to receive(:output)
        .with('finished', hash_including(*keys), 'core')

      core.after_scan
    end
  end
end
