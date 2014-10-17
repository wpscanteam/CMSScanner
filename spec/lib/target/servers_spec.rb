require 'spec_helper'

[:Generic, :Apache, :IIS].each do |server|
  describe CMSScanner::Target do
    subject(:target) do
      described_class.new(url).extend(described_class::Server.const_get(server))
    end
    let(:url)      { 'http://ex.lo' }
    let(:fixtures) { File.join(FIXTURES, 'target', 'server', server.to_s.downcase) }

    it_behaves_like described_class::Server.const_get(server)
  end
end
