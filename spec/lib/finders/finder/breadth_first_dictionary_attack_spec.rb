# frozen_string_literal: true

describe CMSScanner::Finders::Finder::BreadthFirstDictionaryAttack do
  # Dummy class to test the module
  class DummyBreadthFirstDictionaryAttack < CMSScanner::Finders::Finder
    include CMSScanner::Finders::Finder::BreadthFirstDictionaryAttack

    def login_request(username, password)
      Typhoeus::Request.new('http://e.org/login.php',
                            method: :post,
                            body: { username: username, pwd: password })
    end

    def valid_credentials?(response)
      response.code == 302
    end

    def errored_response?(response)
      response.timed_out? || response.body =~ /Error:/
    end
  end

  subject(:finder) { DummyBreadthFirstDictionaryAttack.new(target) }
  let(:target)     { CMSScanner::Target.new('http://e.org') }
  let(:login_url)  { target.url('login.php') }

  describe '#attack' do
    let(:users) { %w[admin root user].map { |u| CMSScanner::Model::User.new(u) } }
    let(:passwords) { %w[pwd admin P@ssw0rd] }

    before do
      # Mock all login requests to 401
      passwords.each do |password|
        users.each do |user|
          stub_request(:post, login_url)
            .with(body: { username: user.username, pwd: password })
            .to_return(status: 401)
        end
      end
    end

    context 'when no valid credentials' do
      it 'does not yield anything' do
        expect { |block| finder.attack(users, passwords, &block) }.not_to yield_control
      end

      context 'when trying to increment above current progress' do
        it 'does not call #increment' do
          # Set the progress of the bar to the total
          expect_any_instance_of(ProgressBar::Base)
            .to receive(:progress)
            .at_least(1)
            .and_return(users.size * passwords.size)

          expect_any_instance_of(ProgressBar::Base)
            .not_to receive(:increment)

          expect { |block| finder.attack(users, passwords, &block) }.not_to yield_control
        end
      end
    end

    context 'when valid credentials' do
      before do
        stub_request(:post, login_url)
          .with(body: { username: 'admin', pwd: 'admin' })
          .to_return(status: 302)
      end

      it 'yields the matching user' do
        expect { |block| finder.attack(users, passwords, &block) }
          .to yield_with_args(CMSScanner::Model::User.new('admin', password: 'admin'))
      end

      context 'when the progressbar total= failed' do
        it 'does not raise an error' do
          expect_any_instance_of(ProgressBar::Base).to receive(:total=).and_raise ProgressBar::InvalidProgressError

          expect { |block| finder.attack(users, passwords, &block) }
            .to yield_with_args(CMSScanner::Model::User.new('admin', password: 'admin'))
        end
      end
    end

    context 'when an error is present in a response' do
      before do
        if defined?(stub_params)
          stub_request(:post, login_url)
            .with(body: { username: 'admin', pwd: 'pwd' })
            .to_return(stub_params)
        else
          stub_request(:post, login_url)
            .with(body: { username: 'admin', pwd: 'pwd' })
            .to_timeout
        end

        CMSScanner::ParsedCli.options = { verbose: defined?(verbose) ? verbose : false }

        finder.attack(users, passwords)
      end

      context 'when request timeout' do
        it 'logs to correct message' do
          expect(finder.progress_bar.log).to eql [
            'Error: Request timed out.'
          ]
        end
      end

      context 'when status/code = 0' do
        let(:stub_params) { { status: 0, body: 'Error: Down' } }

        it 'logs to correct message' do
          expect(finder.progress_bar.log).to eql [
            'Error: No response from remote server. WAF/IPS? ()'
          ]
        end
      end

      context 'when error 500' do
        let(:stub_params) { { status: 500, body: 'Error: 500' } }

        it 'logs to correct message' do
          expect(finder.progress_bar.log).to eql [
            'Error: Server error, try reducing the number of threads.'
          ]
        end
      end

      context 'when unknown error' do
        let(:stub_params) { { status: 200, body: 'Error: Something went wrong' } }

        context 'when no --verbose' do
          let(:verbose) { false }

          it 'logs to correct message' do
            expect(finder.progress_bar.log).to eql [
              'Error: Unknown response received Code: 200'
            ]
          end
        end

        context 'when --verbose' do
          let(:verbose) { true }

          it 'logs to correct message' do
            expect(finder.progress_bar.log).to eql [
              "Error: Unknown response received Code: 200\nBody: Error: Something went wrong"
            ]
          end
        end
      end
    end
  end
end
