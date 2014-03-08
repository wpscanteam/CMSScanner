module CMSScanner
  module Formatter
    # Base & Default Formatter
    class Cli
      def format
        'cli'
      end

      # @param [ String ] tpl
      # @param [ Hash ] vars
      def render(tpl, vars)
      end

      # @param [ String ] tpl
      # @return [ String ] The view file path
      def view_file(tpl)
        fail "Wrong tpl format: '#{tpl}'" unless tpl =~ /\A[\w\/]+\z/

        views_directories.reverse.each do |dir|
          potential_file = File.join(dir, format, "#{tpl}.erb")

          return potential_file if File.exist?(potential_file)
        end

        fail "View not found for #{tpl}"
      end

      def views_directories
        @views_directories ||= []
      end
    end
  end
end
