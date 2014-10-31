
shared_examples 'WordPress::CustomDirectories' do
  let(:fixtures) { File.join(super(), 'custom_directories') }

  describe '#content_dir' do
    {
      default: 'wp-content', https: 'wp-content', custom_w_spaces: 'custom content spaces'
    }.each do |file, expected|
      it "returns #{expected} for #{file}.html" do
        fixture = File.join(fixtures, "#{file}.html")

        stub_request(:get, target.url).to_return(body: File.read(fixture))

        expect(target.content_dir).to eql expected
      end
    end
  end

  describe '#content_dir=, #plugins_dir=' do
    ['wp-content' 'wp-custom'].each do |dir|
      context "when content_dir = #{dir} and no plugins_dir" do
        before { target.content_dir = dir }

        its(:content_dir) { should eq dir.chomp('/') }
        its(:plugins_dir) { should eq dir.chomp('/') + '/plugins' }
      end

      context "when content_dir = #{dir} and plugins_dir = #{dir}" do
        before do
          target.content_dir = dir
          target.plugins_dir = dir
        end

        its(:content_dir) { should eq dir.chomp('/') }
        its(:plugins_dir) { should eq dir.chomp('/') }
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
