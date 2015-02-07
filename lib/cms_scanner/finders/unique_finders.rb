module CMSScanner
  module Finders
    # Unique Finders container
    #
    # This class is designed to return a unique result such as a version
    # Note: Finders contained can return multiple results but the #run will only
    # returned the best finding
    class UniqueFinders < IndependentFinders
      # @param [ Hash ] opts
      # @option opts [ Symbol ] :mode :mixed, :passive or :aggressive
      # @option opts [ Int ] :confidence_threshold  If a finding's confidence reaches this value,
      #                                             it will be returned as the best finding.
      #                                             Default is 100.
      #                                             If <= 0, all finders will be ran.
      #
      # @return [ Object ]
      def run(opts = {})
        opts[:confidence_threshold] ||= 100

        symbols_from_mode(opts[:mode]).each do |symbol|
          each do |finder|
            [*finder.send(symbol, opts)].each { |found| findings << found }

            next if opts[:confidence_threshold] <= 0

            findings.each { |f| return f if f.confidence >= opts[:confidence_threshold] }
          end
        end

        # results are sorted by confidence ASC
        findings.sort_by!(&:confidence)

        # If all findings have the same confidence, nil is returned
        findings.size > 1 && findings[0].confidence == findings[1].confidence ? nil : findings.last
      end
    end
  end
end
