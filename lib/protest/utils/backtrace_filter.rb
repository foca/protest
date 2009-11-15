module Protest
  module Utils
    # Small utility object to filter an error's backtrace and remove any mention
    # of Protest's own files.
    class BacktraceFilter
      ESCAPE_PATHS = [
        # Path to the library's 'lib' dir.
        /^#{Regexp.escape(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))))}/,
      ]

      # Convenience method to clean the API a bit
      def self.filter(backtrace)
        new.filter_backtrace(backtrace)
      end

      # Filter the backtrace, removing any reference to files located in
      # BASE_PATH.
      def filter_backtrace(backtrace, prefix=nil)
        ESCAPE_PATHS << prefix unless prefix.nil?
        backtrace.reject do |line|
          file = line.split(":").first
          ESCAPE_PATHS.any? {|path| File.expand_path(file) =~ path }
        end
      end
    end
  end
end
