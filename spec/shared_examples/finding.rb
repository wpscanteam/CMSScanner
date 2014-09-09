
shared_examples CMSScanner::Finders::Finding do

  describe '#references' do
    its(:references) { should eq [] }
  end

  describe '#confirmed_by' do
    its(:confirmed_by) { should eq [] }
  end

  describe '#parse_finding_options' do
    xit
  end

end
