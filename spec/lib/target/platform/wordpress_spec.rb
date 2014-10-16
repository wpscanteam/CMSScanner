require 'spec_helper'

describe CMSScanner::Target do
  subject(:target) { described_class.new(url).extend(described_class::Platform::WordPress) }
  let(:url)        { 'http://ex.lo' }
  let(:fixtures)   { File.join(FIXTURES, 'target', 'platform', 'wordpress') }

  it_behaves_like described_class::Platform::WordPress
end
