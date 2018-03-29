require 'spec_helper'

describe CMSScanner::Finders::Finder::BreadthFirstDictionaryAttack do
  # Dummy class to test the module
  class DummyBreadthFirstDictionaryAttack < CMSScanner::Finders::Finder
    include CMSScanner::Finders::Finder::BreadthFirstDictionaryAttack
  end

  subject(:finder) { DummyBreadthFirstDictionaryAttack.new(target) }
  let(:target)     { CMSScanner::Target.new('http://e.org') }

  describe '#attack' do
    xit
  end
end
