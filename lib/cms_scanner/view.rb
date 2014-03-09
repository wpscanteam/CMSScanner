module CMSScanner
  module Formatter
    # View
    class View
      attr_reader :path

      def initialize(path)
        @path = path
      end

      # @param [ Hash ] vars
      def render(vars = {})
        template_vars(vars)

        ERB.new(File.read(@path)).result(binding)
      end

      # @return [ Void ]
      def template_vars(vars)
        vars.each { |key, value| instance_variable_set("@#{key}", value) }
      end
    end
  end
end
