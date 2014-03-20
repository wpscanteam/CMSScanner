require 'spec_helper'

module CMSScanner
  module Controller
    class Spec < Base
    end
  end
end

describe CMSScanner::Controllers do

  subject(:controllers) { described_class.new }

  describe '#<<' do
    its(:size) { should be 0 }

    context 'when controllers are added' do
      before { controllers << CMSScanner::Controller::Spec.new << CMSScanner::Controller::Base.new }

      its(:size) { should be 2 }
    end

    context 'when a controller is added twice' do
      before { 2.times { controllers << CMSScanner::Controller::Spec.new } }

      its(:size) { should be 1 }
    end

    it 'returns self' do
      (controllers << CMSScanner::Controller::Spec.new).should be_a described_class
    end
  end

  describe '#run' do
    xit
  end

end
