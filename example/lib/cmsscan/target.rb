# frozen_string_literal: true

module CMSScan
  # Custom Target Class
  class Target < CMSScanner::Target
    # Put your own methods there

    # Method which should be defined.
    # Used to set a specific exit code if the scan found issues
    # See the CMSScanner/lib/cms_scanner/exit_code.rb
    def vulnerable?
      false
    end
  end
end
