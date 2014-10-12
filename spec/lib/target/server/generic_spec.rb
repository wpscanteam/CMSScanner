require 'spec_helper'

# TODO: put this as a shared example for the Target
describe CMSScanner::Target::Server::Generic do
  subject(:target) { CMSScanner::Target.new(url).extend(CMSScanner::Target::Server::Generic) }
  let(:url)        { 'http://ex.lo' }
  let(:fixtures)   { File.join(FIXTURES, 'target', 'server', 'generic') }

  describe '#server' do
    before { stub_request(:head, target.url).to_return(headers: parse_headers_file(fixture)) }

    context 'when apache headers' do
      %w(basic.txt).each do |file|
        let(:fixture) { File.join(fixtures, 'server', 'apache', file) }

        its(:server) { should eq :apache }
      end
    end

    context 'when iis headers' do
      %w(basic.txt).each do |file|
        let(:fixture) { File.join(fixtures, 'server', 'iis', file) }

        its(:server) { should eq :iis }
      end
    end

    context 'not detected' do
      let(:fixture) { File.join(fixtures, 'server', 'not_detected.txt') }

      its(:server) { should be nil }
    end
  end
end
