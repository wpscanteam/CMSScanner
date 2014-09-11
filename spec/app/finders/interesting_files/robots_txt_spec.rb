require 'spec_helper'

describe CMSScanner::Finders::InterestingFile::RobotsTxt do

  subject(:finder) { described_class.new(target) }
  let(:target)     { CMSScanner::Target.new(url) }
  let(:url)        { 'http://example.com/' }
  let(:robots_txt) { url + 'robots.txt' }
  let(:fixtures)   { File.join(FIXTURES, 'interesting_files', 'robots_txt') }

  describe '#url' do
    its(:url) { should eq robots_txt }
  end

  describe '#aggressive' do
    after do
      stub_request(:get, robots_txt).to_return(status: status, body: body)

      result = finder.aggressive

      expect(result).to be_a CMSScanner::RobotsTxt if @expected
      expect(finder.aggressive).to eql @expected
    end

    let(:body) { '' }

    context 'when 404' do
      let(:status) { 404 }

      it 'returns nil' do
        @expected = nil
      end
    end

    context 'when 200' do
      let(:status) { 200 }

      context 'when the body is empty' do
        it 'returns nil' do
          @expected = nil
        end
      end

      context 'when the body matches a robots.txt' do
        let(:body) { File.new(File.join(fixtures, 'robots.txt')).read }

        it 'returns the InterestingFile result' do
          @expected = CMSScanner::RobotsTxt.new(robots_txt,
                                                confidence: 100,
                                                found_by: 'RobotsTxt (aggressive detection)')
        end
      end
    end
  end

end
