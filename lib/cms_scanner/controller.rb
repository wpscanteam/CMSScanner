module CMSScanner
  module Controller
    # Base Controller
    class Base
      # @return [ Array<OptParseValidator::OptBase> ]
      def cli_options; end

      def before_scan; end

      def run; end

      def after_scan; end

      # @return [ Target ]
      def target
        @@target ||= Target.new(parsed_options[:url])
      end

      # TODO: This should be in the formatter
      # @return [ Boolean ]
      def verbose?
        parsed_options[:verbose]
      end

      # @param [ Hash ] options
      def self.parsed_options=(options)
        @@parsed_options = options
      end

      # @return [ Hash ]
      def parsed_options
        @@parsed_options ||= {}
      end

      # @return [ Formatter::Base ]
      def formatter
        @@formatter ||= Formatter.load(parsed_options[:format])
      end

      # @param [ String ] tpl
      # @param [ Hash ] vars
      #
      # @return [ Void ]
      def output(tpl, vars = {})
        formatter.output(
          "#{self.class.name.demodulize.downcase}/#{tpl}",
          instance_variable_values.merge(vars)
        )
      end

      # @param [ String ] tpl
      # @param [ Hash ] vars
      #
      # @return [ String ]
      def render(tpl, vars = {})
        formatter.render(
          "#{self.class.name.demodulize.downcase}/#{tpl}",
          instance_variable_values.merge(vars)
        )
      end

      # @return [ Hash ] All the instance variable keys associated and their values
      def instance_variable_values
        h = {}
        instance_variables.each do |a|
          s    = a.to_s
          n    = s[1..s.size]
          h[n] = instance_variable_get(a)
        end
        h
      end
    end
  end
end
