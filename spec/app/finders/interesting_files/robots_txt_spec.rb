require 'spec_helper'

describe CMSScanner::Finders::InterestingFile::RobotsTxt do

  subject(:finder) { described_class.new(target) }
  let(:target)     { CMSScanner::Target.new(url) }
  let(:url)        { 'http://example.com/' }
  let(:robot_txt)  { url + 'robots.txt' }

  describe '#url' do
    its(:url) { should eq robot_txt }
  end

  describe '#aggressive' do
    after do
      stub_request(:get, robot_txt).to_return(status: status)

      expect(finder.aggressive).to eql @expected
    end

    context 'when 404' do
      let(:status) { 404 }

      it 'returns nil' do
        @expected = nil
      end
    end

    context 'when 200' do
      let(:status) { 200 }

      it 'returns a hash with the result' do
        @expected = CMSScanner::InterestingFile.new(robot_txt,
                                                    confidence: 100,
                                                    found_by: 'RobotsTxt (aggressive detection)')
      end
    end
  end

end
