require 'spec_helper'

describe CMSScanner::Finders::InterestingFile::XMLRPC do

  subject(:finder)  { described_class.new(target) }
  let(:target)      { CMSScanner::Target.new(url) }
  let(:url)         { 'http://ex.lo/' }
  let(:xml_rpc_url) { url + 'xmlrpc.php' }
  let(:fixtures)    { File.join(FIXTURES, 'interesting_files', 'xml_rpc') }

  describe '#potential_urls' do
    its(:potential_urls) { should be_empty }
  end

  describe '#passive' do
    before do
      expect(finder).to receive(:passive_headers).and_return(headers_stub)
      expect(finder).to receive(:passive_body).and_return(body_stub)
    end

    context 'when both passives return nil' do
      let(:headers_stub) { nil }
      let(:body_stub)    { nil }

      its(:passive) { should be_empty }
    end

    context 'when one passive is not nil' do
      let(:headers_stub) { nil }
      let(:body_stub)    { 'test' }

      its(:passive) { should eq %w(test) }
    end
  end

  describe '#passive_headers' do
    before { stub_request(:get, url).to_return(headers: headers) }

    let(:headers) { {} }

    context 'when no headers' do
      its(:passive_headers) { should be_nil }
    end

    context 'when headers' do
      context 'when URL is out of scope' do
        let(:headers) { { 'X-Pingback' => 'http://ex.org/yolo' } }

        its(:passive_headers) { should be_nil }
      end

      context 'when URL is in scope' do
        let(:headers) { { 'X-Pingback' => xml_rpc_url } }

        it 'adds the url to #potential_urls and returns the XMLRPC' do
          result = finder.passive_headers

          expect(finder.potential_urls).to eq [xml_rpc_url]

          expect(result).to be_a CMSScanner::XMLRPC
          expect(result).to eql CMSScanner::XMLRPC.new(
            xml_rpc_url,
            confidence: 30,
            found_by: 'Headers (passive detection)'
          )
        end
      end
    end
  end

  describe '#passive_body' do
    before { stub_request(:get, url).to_return(body: body) }

    context 'when no link rel="pingback" tag' do
      let(:body) { '' }

      its(:passive_body) { should be_nil }
    end

    context 'when the tag is present' do
      context 'when the URL is out of scope' do
        let(:body) { File.new(File.join(fixtures, 'homepage_out_of_scope_pingback.html')).read }

        its(:passive_body) { should be_nil }
      end

      context 'when URL is in scope' do
        let(:body)         { File.new(File.join(fixtures, 'homepage_in_scope_pingback.html')).read }
        let(:expected_url) { 'http://ex.lo/wp/xmlrpc.php' }

        it 'adds the URL to the #potential_urls and returns the XMLRPC' do
          result = finder.passive_body

          expect(finder.potential_urls).to eq [expected_url]

          expect(result).to be_a CMSScanner::XMLRPC
          expect(result).to eql CMSScanner::XMLRPC.new(
            expected_url,
            confidence: 30,
            found_by: 'Link Tag (passive detection)'
          )
        end
      end
    end
  end

  describe '#aggressive' do
    # Adds an out of scope URL which should be ignored
    before { finder.potential_urls << 'htpp://ex.org' }

    after do
      stub_request(:get, xml_rpc_url).to_return(body: body)

      expect(finder.aggressive).to eql @expected
    end

    context 'when the body does not match' do
      let(:body) { '' }

      it 'returns nil' do
        @expected = nil
      end
    end

    context 'when the body matches' do
      let(:body) { File.new(File.join(fixtures, 'xmlrpc.php')).read }

      it 'returns the InterestingFile result' do
        @expected = CMSScanner::XMLRPC.new(
          xml_rpc_url,
          confidence: 100,
          found_by: described_class::DIRECT_ACCESS
        )
      end
    end
  end

end
