require_relative 'wordpress/custom_directories'

shared_examples CMSScanner::Target::Platform::WordPress do
  it_behaves_like 'WordPress::CustomDirectories'

  describe '#wordpress?' do
    let(:fixtures) { File.join(super(), 'detection') }

    before do
      stub_request(:get, target.url).to_return(body: File.read(File.join(fixtures, "#{body}.html")))
    end

    %w(default wp_includes).each do |file|
      context "when a wordpress page (#{file}.html)" do
        let(:body) { file }

        its(:wordpress?) { should be true }
      end
    end

    %w(not_wp).each do |file|
      context "when not a wordpress page (#{file}.html)" do
        let(:body) { file }

        its(:wordpress?) { should be false }
      end
    end
  end

  describe '#wordpress_hosted?' do
    its(:wordpress_hosted?) { should be false }

    context 'when the target host matches' do
      let(:url) { 'http://ex.wordpress.com' }

      its(:wordpress_hosted?) { should be true }
    end
  end
end
