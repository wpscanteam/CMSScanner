module CMSScanner
  # Formatter
  module Formatter
    # @param [ String ] format
    #
    # @return [ Formatter::Base ]
    def self.load(format = nil)
      format ||= 'cli' # default format

      const_get(format.gsub(/-/, '_').camelize).new
    end

    # Base Formatter
    class Base
      # @return [ String ] The underscored name of the class
      def format
        self.class.name.demodulize.underscore
      end

      # This is called after the scan
      # and used in some formatters (e.g JSON)
      # to indent results
      def beautify; end

      # @see #render
      def output(tpl, vars = {})
        puts render(tpl, vars)
      end

      # @param [ String ] tpl
      # @param [ Hash ] vars
      def render(tpl, vars = {})
        template_vars(vars)

        # '-' is used to disable new lines when -%> is used
        # See http://www.ruby-doc.org/stdlib-2.1.1/libdoc/erb/rdoc/ERB.html
        ERB.new(File.read(view_path(tpl)), nil, '-').result(binding)
      end

      # @param [ Hash ] vars
      #
      # @return [ Void ]
      def template_vars(vars)
        vars.each do |key, value|
          instance_variable_set("@#{key}", value) unless key == :views_directories
        end
      end

      # @param [ String ] tpl
      #
      # @return [ String ] The path of the view
      def view_path(tpl)
        fail "Wrong tpl format: '#{tpl}'" unless tpl =~ /\A[\w\/_]+\z/

        views_directories.reverse.each do |dir|
          potential_file = File.join(dir, format, "#{tpl}.erb")

          return potential_file if File.exist?(potential_file)
        end

        fail "View not found for #{format}/#{tpl}"
      end

      # @return [ Array<String> ] The directories to look into for views
      def views_directories
        @views_directories ||= [
          Pathname.new(__FILE__).dirname.join('..', 'views').to_s,
          Pathname.new(Dir.pwd).join('views').to_s
        ]
      end
    end
  end
end
