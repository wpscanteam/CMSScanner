module CMSScanner
  # Exit Code Values
  module ExitCode
    # No error, scan finished w/o any vulnerabilies found
    OK               = 0

    # All exceptions raised by OptParseValidator and OptionParser
    CLI_OPTION_ERROR = 1

    # Interrupt received
    INTERRUPTED      = 2

    # Exceptions
    ERROR            = 3

    # The target has at least one vulnerability.
    # Currently, the interesting findings do not count as vulnerable things
    VULNERABLE       = 4
  end
end
