require 'spec_helper'

# Module included the CMSScanner to test its correct inclusion
module SubScanner
  include CMSScanner

  # This Target class should be called in the CMSScanner::Controller::Base
  # instead of the CMSScanner::Target
  class Target < CMSScanner::Target
    def new_method
      'working'
    end
  end
end

describe SubScanner::Scan do
  subject(:scanner) { described_class.new }
  let(:controller)  { SubScanner::Controller }

  it 'loads the overrided Target class' do
    target = scanner.controllers.first.target

    expect(target).to be_a SubScanner::Target
    expect(target.respond_to?(:new_method)).to eq true
    expect(target.new_method).to eq 'working'
  end
end
