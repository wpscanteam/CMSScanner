require 'spec_helper'

# Module including the CMSScanner to test its correct inclusion
module SubScanner
  include CMSScanner

  # This Target class should be called in the CMSScanner::Controller::Base
  # instead of the CMSScanner::Target
  class Target < CMSScanner::Target
    def new_method
      'working'
    end
  end

  # Custom method for all formatters
  module Formatter
    include CMSScanner::Formatter

    # Implements a #custom method which should be available in all formatters
    module InstanceMethods
      def custom
        'It Works!'
      end
    end
  end
end

describe SubScanner::Scan do
  subject(:scanner)     { described_class.new }
  let(:formatter_class) { SubScanner::Formatter }

  it 'loads the overrided Target class' do
    target = scanner.controllers.first.target

    expect(target).to be_a SubScanner::Target
    expect(target).to respond_to(:new_method)
    expect(target.new_method).to eq 'working'
  end

  it 'adds the #custom method for all formatters' do
    formatter_class.availables.each do |format|
      expect(formatter_class.load(format).custom).to eql 'It Works!'
    end
  end
end
