require 'spec_helper'

describe CMSScanner::Finders::Finder::Fingerprinter do
  # Dummy class to test the module
  class DummyFinder < CMSScanner::Finders::Finder
    include CMSScanner::Finders::Finder::Fingerprinter
  end

  subject(:finder) { DummyFinder.new(target) }
  let(:target)     { CMSScanner::Target.new('http://e.org') }

  its(:browser) { should be_a CMSScanner::Browser }

  its(:request_params) { should eql {} }

  its(:hydra) { should be_a Typhoeus::Hydra }

  describe '#fingerprint' do
    xit

    let(:fingerprints) do
      {
        target.url('f1.css') => {

        },
        target.url('f2.js') => {

        }
      }
    end
  end
end
