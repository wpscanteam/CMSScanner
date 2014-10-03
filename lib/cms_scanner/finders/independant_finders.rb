module CMSScanner
  module Finders
    # Independant Finders container
    # This class is designed to handle independant results
    # which are not related with others
    # e.g: interesting files
    class IndependantFinders < Array
      # @return [ Findings ]
      def findings
        @findings ||= NS::Finders::Findings.new
      end

      # @param [ Hash ] opts
      # @option opts [ Symbol ] mode :mixed, :passive or :aggressive
      #
      # @return [ Findings ]
      def run(opts = {})
        each do |finder|
          symbols_from_mode(opts[:mode]).each do |symbol|
            r = finder.send(symbol, opts)

            next unless r

            findings + [*r]
          end
        end

        findings
      end

      # @param [ Symbol ] mode :mixed, :passive or :aggressive
      # @return [ Array<Symbol> ] The symbols to call for the mode
      def symbols_from_mode(mode)
        symbols = [:passive, :aggressive]

        return symbols if mode.nil? || mode == :mixed
        symbols.include?(mode) ? [*mode] : []
      end
    end
  end
end
