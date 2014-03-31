module CMSScanner
  module Formatter
    # JSON Formatter
    class Json < Base
      def output(tpl, vars = {}, controller_name = nil)
        buffer << render(tpl, vars, controller_name)
      end

      def buffer
        @buffer ||= ''
      end

      def beautify
        puts JSON.pretty_generate(JSON.parse("{#{buffer.chomp.chomp(',')}}"))
      end
    end
  end
end
