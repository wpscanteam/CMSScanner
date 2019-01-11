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
    let(:users) { %w[admin root user].map { |u| CMSScanner::User.new(u) } }
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
    end

    context 'when valid credentials' do
      before do
        stub_request(:post, login_url)
          .with(body: { username: 'admin', pwd: 'admin' })
          .to_return(status: 302)
      end

      it 'yields the matching user' do
        expect { |block| finder.attack(users, passwords, &block) }
          .to yield_with_args(CMSScanner::User.new('admin', password: 'admin'))
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

        it 'logs to correct message' do
          expect(finder.progress_bar.log).to eql [
            "Error: Unknown response received Code: 200\nBody: Error: Something went wrong"
          ]
        end
      end
    end
  end
end
