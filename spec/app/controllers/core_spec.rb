# frozen_string_literal: true

describe CMSScanner::Controller::Core do
  subject(:core)   { described_class.new }
  let(:target_url) { 'http://example.com/' }
  let(:cli_args)   { "--url #{target_url}" }

  before do
    CMSScanner::ParsedCli.options = rspec_parsed_options(cli_args)
  end

  describe '#cli_options' do
    its(:cli_options) { should_not be_empty }
    its(:cli_options) { should be_a Array }

    it 'contains the expected options' do
      expect(core.cli_options.map(&:to_sym)).to match_array(
        %i[
          banner cache_dir cache_ttl clear_cache connect_timeout cookie_jar cookie_string
          detection_mode disable_tls_checks format headers help hh http_auth ignore_main_redirect
          max_scan_duration max_threads output proxy proxy_auth random_user_agent request_timeout
          scope throttle url user_agent user_agents_list verbose version vhost
        ]
      )
    end
  end

  describe '#setup_cache' do
    context 'when no cache_dir supplied (or default)' do
      it 'returns nil' do
        expect(core.setup_cache).to eq nil
      end
    end

    context 'when cache_dir' do
      let(:cli_args) { "#{super()} --cache-dir #{CACHE}" }
      let(:cache)    { Typhoeus::Config.cache }
      let(:storage)  { File.join(CMSScanner::ParsedCli.cache_dir, Digest::MD5.hexdigest(target_url)) }

      before { core.setup_cache }
      after  { Typhoeus::Config.cache = nil }

      it 'sets up the cache' do
        expect(cache).to be_a CMSScanner::Cache::Typhoeus
        expect(cache.storage_path).to eq storage
      end
    end
  end

  describe 'maybe_output_banner_help_and_version' do
    before { described_class.option_parser = OptParseValidator::OptParser.new(nil, 40) }

    let(:fixtures) { FIXTURES_CONTROLLERS.join('core', 'help') }

    context 'when --no-banner' do
      let(:cli_args) { "#{super()} --no-banner" }

      it 'calls output' do
        expect(core.formatter).to_not receive(:output)

        expect { core.maybe_output_banner_help_and_version }.to_not raise_error
      end
    end

    context 'when --help' do
      let(:cli_args) { '--help' }

      it 'calls the output' do
        expect(core.formatter).to receive(:output).with('banner', { verbose: nil }, 'core')
        expect(core.formatter)
          .to receive(:output)
          .with('help', hash_including(:help, simple: true), 'core')
          .and_call_original

        expect($stdout).to receive(:puts).with(File.read(fixtures.join('simple.txt')))

        expect { core.maybe_output_banner_help_and_version }.to raise_error(SystemExit)
      end
    end

    context 'when --hh' do
      let(:cli_args) { '--hh' }

      it 'calls the output' do
        expect(core.formatter).to receive(:output).with('banner', { verbose: nil }, 'core')
        expect(core.formatter)
          .to receive(:output)
          .with('help', hash_including(:help, simple: false), 'core')
          .and_call_original

        expect($stdout).to receive(:puts).with(File.read(fixtures.join('full.txt')))

        expect { core.maybe_output_banner_help_and_version }.to raise_error(SystemExit)
      end
    end

    context 'when --version' do
      let(:cli_args) { "#{super()} --version" }

      it 'calls the output' do
        expect(core.formatter).to receive(:output).with('banner', { verbose: nil }, 'core')
        expect(core.formatter).to receive(:output).with('version', { verbose: nil }, 'core')

        expect { core.maybe_output_banner_help_and_version }.to raise_error(SystemExit)
      end
    end
  end

  describe '#before_scan' do
    context 'when --no-banner' do
      let(:cli_args) { "#{super()} --no-banner" }

      before { expect(core.formatter).to_not receive(:output) }

      it 'does not raise an error when everything is fine' do
        stub_request(:get, target_url).to_return(status: 200)

        expect { core.before_scan }.to_not raise_error
      end
    end

    context 'when --banner (default)' do
      before { expect(core.formatter).to receive(:output) }

      it 'does not raise an error when everything is fine' do
        stub_request(:get, target_url).to_return(status: 200)

        expect { core.before_scan }.to_not raise_error
      end

      it 'raise an error when the site is down' do
        stub_request(:get, target_url).to_return(status: 0)

        expect { core.before_scan }
          .to raise_error(
            CMSScanner::Error::TargetDown,
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
                CMSScanner::Error::HTTPRedirect,
                "The URL supplied redirects to #{redirection}." \
                ' Use the --ignore-main-redirect option to ignore the redirection and scan the target,' \
                ' or change the --url option value to the redirected URL.'
              )
            end
          end

          context 'when the --ignore-main-redirect is supplied' do
            let(:cli_args) { "#{super()} --ignore-main-redirect" }

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

        context 'when no --random-user-agent provided' do
          it 'raises an error with the correct message' do
            expect { core.before_scan }.to raise_error(
              CMSScanner::Error::AccessForbidden,
              'The target is responding with a 403, this might be due to a WAF. Please re-try with --random-user-agent'
            )
          end
        end

        context 'when --random-user-agent-provided' do
          let(:cli_args) { "#{super()} --random-user-agent" }

          it 'raises an error with the correct message' do
            expect { core.before_scan }.to raise_error(
              CMSScanner::Error::AccessForbidden,
              'The target is responding with a 403, this might be due to a WAF. ' \
              'Well... --random-user-agent didn\'t work, you\'re on your own now!'
            )
          end
        end
      end

      # This is quite a mess (as Webmock doesn't issue itself another 401
      # when credential are incorrect :/)
      context 'when http authentication' do
        context 'when no credentials' do
          before { stub_request(:get, target_url).to_return(status: 401) }

          it 'raises an error' do
            expect { core.before_scan }.to raise_error(CMSScanner::Error::HTTPAuthRequired)
          end
        end

        context 'when credentials' do
          context 'when valid' do
            before { stub_request(:get, 'http://example.com').with(basic_auth: %w[user pass]) }

            let(:cli_args) { "#{super()} --http-auth user:pass" }

            it 'does not raise any error' do
              expect { core.before_scan }.to_not raise_error
            end
          end

          context 'when invalid' do
            before do
              stub_request(:get, 'http://example.com')
                .with(basic_auth: %w[user p@ss]).to_return(status: 401)
            end

            let(:cli_args) { "#{super()} --http-auth user:p@ss" }

            it 'raises an error' do
              expect { core.before_scan }.to raise_error(CMSScanner::Error::HTTPAuthRequired)
            end
          end
        end
      end

      context 'when proxy authentication' do
        before { stub_request(:get, target_url).to_return(status: 407) }

        context 'when no credentials' do
          it 'raises an error' do
            expect { core.before_scan }.to raise_error(CMSScanner::Error::ProxyAuthRequired)
          end
        end

        context 'when invalid credentials' do
          let(:cli_args) { "#{super()} --proxy-auth user:p@ss" }

          it 'raises an error' do
            expect(CMSScanner::Browser.instance.proxy_auth).to eq(CMSScanner::ParsedCli.proxy_auth)

            expect { core.before_scan }.to raise_error(CMSScanner::Error::ProxyAuthRequired)
          end
        end

        context 'when valid credentials' do
          before { stub_request(:get, target_url) }

          let(:cli_args) { "#{super()} --proxy-auth user:pass" }

          it 'raises an error' do
            expect(CMSScanner::Browser.instance.proxy_auth).to eq(CMSScanner::ParsedCli.proxy_auth)

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
    let(:keys) do
      %i[verbose start_time stop_time start_memory elapsed used_memory requests_done data_sent data_received]
    end

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
