module CMSScanner
  module Finders
    # Independent Finders container
    # This class is designed to handle independent results
    # which are not related with each others
    # e.g: interesting files
    class IndependentFinders < Array
      # @return [ Findings ]
      def findings
        @findings ||= NS::Finders::Findings.new
      end

      # @param [ Hash ] opts
      # @option opts [ Symbol ] mode :mixed, :passive or :aggressive
      #
      # @return [ Findings ]
      def run(opts = {})
        methods = symbols_from_mode(opts[:mode])

        each do |finder|
          methods.each do |symbol|
            [*finder.send(symbol, opts.merge(found: findings))].compact.each do |found|
              findings << found
            end
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
