require 'shared_examples/wordpress/custom_directories'

shared_examples CMSScanner::Target::Platform::WordPress do

  it_behaves_like 'WordPress::CustomDirectories'

  describe '#wordpress?' do
    xit
  end

  describe '#wordpress_hosted?' do
    xit
  end

end
