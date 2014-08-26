require 'spec_helper'

describe CMSScanner::Finder::Finding do

  subject(:finding) { described_class.new(result) }
  let(:result)      { 'test' }

  describe '#new' do
    its(:result)     { should eq result }
    its(:confidence) { should be_nil }
    its(:method)     { should be_nil }
  end

  describe '#to_s' do
    its(:to_s) { should eq result.to_s }
  end

end
