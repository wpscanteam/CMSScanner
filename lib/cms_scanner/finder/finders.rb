module CMSScanner
  module Finder
    # Finder container
    class Finders < Array
      # @param [ Symbol ] mode :mixed, :passive or :aggressive
      # @param [ Hash ] opts
      #
      # @return [ Findings ]
      def run(mode = :mixed, opts = {})
        each do |finder|
          symbols_from_mode(mode).each do |symbol|
            r = finder.send(symbol, opts)

            next unless r

            # TODO: create another method doing the below
            method     = "#{finder.class.to_s.demodulize} (#{symbol} detection)"
            confidence = nil
            result     = r

            if r.is_a?(Hash) && r.key?(:result)
              result     = r[:result]
              method     = r[:method] if r.key?(:method)
              confidence = r[:confidence] if r.key?(:confidence)
            end

            findings << Finding.new(result, method, confidence)
          end
        end
        findings
      end

      # @param [ symbol ] mode :mixed, :passive or :aggressive
      # @return [ Array<Symbol> ] The symbols to call for the mode
      def symbols_from_mode(mode)
        symbols = [:passive, :aggressive]

        return symbols if mode == :mixed
        symbols.include?(mode) ? [*mode] : []
      end

      def findings
        @findings ||= Findings.new
      end
    end
  end
end
