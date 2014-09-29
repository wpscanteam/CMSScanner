module CMSScanner
  module Controller
    # InterestingFiles Controller
    class InterestingFiles < Base
      def run
        findings = target.interesting_files # TODO: add the detection_mode option

        output('findings', findings: findings) unless findings.empty?
      end
    end
  end
end
