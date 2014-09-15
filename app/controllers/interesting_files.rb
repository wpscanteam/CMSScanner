module CMSScanner
  module Controller
    # InterestingFiles Controller
    class InterestingFiles < Base
      def run
        findings = Finders::InterestingFiles.find(target)

        output('findings', findings: findings) unless findings.empty?
      end
    end
  end
end
