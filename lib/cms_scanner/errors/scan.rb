module CMSScanner
  # Used instead of the Timeout::Error
  class MaxScanDurationReachedError < Error
    # :nocov:
    def to_s
      'Max Scan Duration Reached'
    end
    # :nocov:
  end
end
