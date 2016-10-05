module CMSScanner
  module Controller
    # InterestingFindings Controller
    class InterestingFindings < Base
      def cli_options
        [
          OptChoice.new(
            ['--interesting-findings-detection MODE',
             'Use the supplied mode for the interesting findings detection. '],
            choices: %w(mixed passive aggressive),
            normalize: :to_sym
          )
        ]
      end

      def run
        mode = parsed_options[:interesting_findings_detection] || parsed_options[:detection_mode]
        findings = target.interesting_findings(mode: mode)

        output('findings', findings: findings) unless findings.empty?
      end
    end
  end
end
