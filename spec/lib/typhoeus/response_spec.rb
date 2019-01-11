describe Typhoeus::Response do
  subject(:response) { Typhoeus::Response.new(opts) }
  let(:opts)         { { body: 'hello world' } }

  describe 'html' do
    its(:xml) { should be_a Nokogiri::XML::Document }
  end

  describe 'xml' do
    its(:xml) { should be_a Nokogiri::XML::Document }
  end

  describe 'request_size' do
    its(:request_size) { should eql 0 }
  end

  describe 'size' do
    context 'when no headers' do
      its(:size) { should eql 11 }
    end

    context 'when headers' do
      let(:opts) { super().merge(response_headers: "key: value\r\n") }

      its(:size) { should eql 23 }
    end
  end
end
