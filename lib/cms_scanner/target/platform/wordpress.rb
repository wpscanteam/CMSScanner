%w(custom_directories).each do |required|
  require "cms_scanner/target/platform/wordpress/#{required}"
end

module CMSScanner
  class Target < WebSite
    module Platform
      # Some WordPress specific implementation
      module WordPress
        include PHP

        def wordpress?
        end

        def wordpress_hosted?
        end
      end
    end
  end
end
