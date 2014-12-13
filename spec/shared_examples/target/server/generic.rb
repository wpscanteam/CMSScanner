require 'spec_helper'

shared_examples CMSScanner::Target::Server::Generic do
  describe '#server' do
    before { stub_request(:head, target.url).to_return(headers: parse_headers_file(fixture)) }

    context 'when apache headers' do
      %w(basic.txt).each do |file|
        context "when #{file} headers" do
          let(:fixture) { File.join(fixtures, 'server', 'apache', file) }

          its(:server) { should eq :Apache }
        end
      end
    end

    context 'when iis headers' do
      %w(basic.txt).each do |file|
        context "when #{file} headers" do
          let(:fixture) { File.join(fixtures, 'server', 'iis', file) }

          its(:server) { should eq :IIS }
        end
      end
    end

    context 'not detected' do
      let(:fixture) { File.join(fixtures, 'server', 'not_detected.txt') }

      its(:server) { should be nil }
    end
  end
end
