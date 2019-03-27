# frozen_string_literal: true

module CMSScan
  # Needed to load at least the Core controller
  # Otherwise, the following error will be raised:
  # `initialize': uninitialized constant CMSScan::Controller::Core (NameError)
  module Controller
    include CMSScanner::Controller
  end
end
