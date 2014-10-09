require 'spec_helper'

describe CMSScanner::Target::Platform::PHP do
  subject(:target) { CMSScanner::Target.new(url).extend(CMSScanner::Target::Platform::PHP) }
  let(:url)        { 'http://ex.lo' }
  let(:fixtures)   { File.join(FIXTURES, 'target', 'platform', 'php', 'debug_log') }

  describe '#debug_log?' do
    before     { stub_request(:get, target.url(path)).to_return(body: body) }
    let(:path) { 'd.log' }

    context 'when the body matches' do
      %w(debug.log).each do |file|
        let(:body) { File.read(File.join(fixtures, file)) }

        it 'returns true' do
          expect(target.debug_log?(path)).to be true
        end
      end
    end

    context 'when the body does not match' do
      let(:body) { '' }

      it 'returns false' do
        expect(target.debug_log?(path)).to be false
      end
    end
  end

end
