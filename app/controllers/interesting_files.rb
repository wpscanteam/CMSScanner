module CMSScanner
  module Controller
    # InterestingFiles Controller
    class InterestingFiles < Base
      def cli_options
        [
          OptChoice.new(
            ['--interesting-files-detection MODE',
             'Use the supplied mode for the interesting files detection. ' \
             'Modes: mixed, passive, aggressive'
            ],
            choices: %w(mixed passive aggressive),
            normalize: :to_sym)
        ]
      end

      def run
        mode     = parsed_options[:interesting_files_detection] || parsed_options[:detection_mode]
        findings = target.interesting_files(mode: mode)

        output('findings', findings: findings) unless findings.empty?
      end
    end
  end
end
