# frozen_string_literal: true

describe CMSScanner::Target do
  subject(:target) { described_class.new(url, opts) }
  let(:url)        { 'http://e.org' }
  let(:fixtures)   { FIXTURES.join('target', 'scope') }
  let(:opts)       { { scope: nil } }

  describe '#scope' do
    let(:default_domains) { [PublicSuffix.parse('e.org')] }

    context 'when none supplied' do
      its('scope.domains') { should eq default_domains }
    end

    context 'when scope provided' do
      let(:opts) { super().merge(scope: ['*.e.org']) }

      its('scope.domains') { should eq default_domains << PublicSuffix.parse(opts[:scope].first) }

      context 'when invalid domains provided' do
        let(:opts) { super().merge(scope: ['wp-lamp']) }

        it 'adds them in the invalid_domains attribute' do
          expect(target.scope.domains).to eq default_domains
          expect(target.scope.invalid_domains).to eq opts[:scope]
        end
      end
    end
  end

  describe '#in_scope?' do
    context 'when default scope (target domain)' do
      [nil, '', 'http://out-of-scope.com', '//jquery.com/j.js',
       'javascript:alert(3)', 'mailto:p@g.com'].each do |url|
        it "returns false for #{url}" do
          expect(target.in_scope?(url)).to eql false
        end
      end

      %w[https://e.org/file.txt http://e.org/ //e.org].each do |url|
        it "returns true for #{url}" do
          expect(target.in_scope?(url)).to eql true
        end
      end
    end

    context 'when custom scope' do
      let(:opts) { { scope: ['*.cdn.com', '192.168.1.12', '*.cloudfront.net'] } }

      [nil, '', 'http://out-of-scope.com', '//jquery.com/j.js', 'http://192.168.1.2/'].each do |url|
        it "returns false for #{url}" do
          expect(target.in_scope?(url)).to eql false
        end
      end

      %w[
        https://e.org //aa.cdn.com/f.txt http://s.cdn.com/
        https://192.168.1.12/h https://aa.cloudfront.net/
      ].each do |url|
        it "returns true for #{url}" do
          expect(target.in_scope?(url)).to eql true
        end
      end
    end
  end

  describe '#in_scope_urls' do
    let(:res) { Typhoeus::Response.new(body: File.read(fixtures.join('index.html'))) }

    context 'when block given' do
      it 'yield the url' do
        expect { |b| target.in_scope_urls(res, &b) }
          .to yield_successive_args(
            ['http://e.org/f.txt', Nokogiri::XML::Element],
            ['http://e.org/script/s.js', Nokogiri::XML::Element],
            ['http://e.org/feed', Nokogiri::XML::Element]
          )
      end
    end

    context 'when xpath argument given' do
      it 'returns the expected array' do
        xpath = '//link[@rel="alternate" and @type="application/rss+xml"]/@href'

        expect(target.in_scope_urls(res, xpath)).to eql(%w[http://e.org/feed])
      end
    end

    context 'when no block given' do
      after { expect(target.in_scope_urls(res)).to eql @expected }

      context 'when default scope' do
        it 'returns the expected array' do
          @expected = %w[http://e.org/f.txt http://e.org/script/s.js http://e.org/feed]
        end
      end

      context 'when supplied scope' do
        let(:opts) { super().merge(scope: ['*.cdn.com', 'wp-lamp']) }

        it 'returns the expected array' do
          @expected = %w[http://e.org/f.txt https://a.cdn.com/f2.js http://e.org/script/s.js
                         http://wp-lamp/robots.txt http://e.org/feed]
        end
      end
    end
  end
end
