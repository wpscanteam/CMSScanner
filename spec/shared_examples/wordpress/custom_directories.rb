
shared_examples 'WordPress::CustomDirectories' do
  let(:fixtures) { File.join(super(), 'custom_directories') }

  describe '#content_dir' do
    {
      default: 'wp-content', https: 'wp-content', custom_w_spaces: 'custom content spaces'
    }
    .each do |file, expected|
      it "returns #{expected} for #{file}.html" do
        fixture = File.join(fixtures, "#{file}.html")

        stub_request(:get, target.url).to_return(body: File.read(fixture))

        expect(target.content_dir).to eql expected
      end
    end
  end

  describe '#content_uri, #content_url, #plugins_uri, #plugins_url' do
    before { target.content_dir = 'wp-content' }

    its(:content_uri) { should eq Addressable::URI.parse("#{url}/wp-content/") }
    its(:content_url) { should eq "#{url}/wp-content/" }

    its(:plugins_uri) { should eq Addressable::URI.parse("#{url}/wp-content/plugins/") }
    its(:plugins_url) { should eq "#{url}/wp-content/plugins/" }
  end
end
