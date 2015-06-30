module CMSScanner
  module Controller
    # Base Controller
    class Base
      include OptParseValidator

      # @return [ Array<OptParseValidator::OptBase> ]
      def cli_options; end

      def before_scan; end

      def run; end

      def after_scan; end

      def ==(other)
        self.class == other.class
      end

      # Reset all the class attibutes
      # Currently only used in specs
      def self.reset
        @@target         = nil
        @@parsed_options = nil
        @@datastore      = nil
        @@formatter      = nil
      end

      # @return [ Target ]
      def target
        @@target ||= NS::Target.new(parsed_options[:url], parsed_options)
      end

      # Set the parsed options and initialize the browser
      # with them
      #
      # @param [ Hash ] options
      def self.parsed_options=(options)
        @@parsed_options = options

        NS::Browser.instance(options)
      end

      # @return [ Hash ]
      def parsed_options
        @@parsed_options ||= {}
      end

      # @return [ Hash ]
      def datastore
        @@datastore ||= {}
      end

      # @return [ Formatter::Base ]
      def formatter
        @@formatter ||= NS::Formatter.load(parsed_options[:format], datastore[:views])
      end

      # @see Formatter#output
      #
      # @return [ Void ]
      def output(tpl, vars = {})
        formatter.output(*tpl_params(tpl, vars))
      end

      # @see Formatter#render
      #
      # @return [ String ]
      def render(tpl, vars = {})
        formatter.render(*tpl_params(tpl, vars))
      end

      # @return [ Boolean ]
      def user_interaction?
        formatter.user_interaction? && !parsed_options[:output]
      end

      # @return [ String ]
      def tmp_directory
        File.join('/tmp', NS.to_s.underscore)
      end

      protected

      # @param [ String ] tpl
      # @param [ Hash ] vars
      #
      # @return [ Array<String> ]
      def tpl_params(tpl, vars)
        [
          tpl,
          instance_variable_values.merge(vars),
          self.class.name.demodulize.underscore
        ]
      end

      # @return [ Hash ] All the instance variable keys (and their values) and the verbose value
      def instance_variable_values
        h = { verbose: parsed_options[:verbose] }
        instance_variables.each do |a|
          s    = a.to_s
          n    = s[1..s.size]
          h[n.to_sym] = instance_variable_get(a)
        end
        h
      end
    end
  end
end
