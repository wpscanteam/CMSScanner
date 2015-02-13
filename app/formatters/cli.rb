module CMSScanner
  module Formatter
    # CLI Formatter
    class Cli < Base
      def bold(text)
        colorize(text, 1)
      end

      def red(text)
        colorize(text, 31)
      end

      def green(text)
        colorize(text, 32)
      end

      def amber(text)
        colorize(text, 33)
      end

      def blue(text)
        colorize(text, 34)
      end

      def colorize(text, color_code)
        "\e[#{color_code}m#{text}\e[0m"
      end
    end
  end
end
