module CMSScanner
  module Controller
    # InterestingFiles Controller
    class InterestingFiles < Base
      def run
        findings = target.interesting_files(mode: parsed_options[:detection_mode])

        output('findings', findings: findings) unless findings.empty?
      end
    end
  end
end
