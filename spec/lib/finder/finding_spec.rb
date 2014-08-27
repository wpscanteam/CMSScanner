require 'spec_helper'

describe CMSScanner::Finder::Finding do

  subject(:finding) { described_class.new(result, opts) }
  let(:result)      { 'test' }
  let(:opts)        { {} }

  describe '#new' do
    its(:result)     { should eq result }
    its(:confidence) { should be_nil }
    its(:method)     { should be_nil }
    its(:references) { should eq [] }

    context 'when :references is a string' do
      let(:opts) { { references: 'some-url' } }

      its(:references) { should eq %w(some-url) }
    end
  end

  describe '#to_s' do
    its(:to_s) { should eq result.to_s }
  end

end
