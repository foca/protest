module Protest
  module Utils
    # Small utility object to filter an error's backtrace and remove any mention
    # of Protest's own files.
    class BacktraceFilter
      ESCAPE_PATHS = [
        # Path to the library's 'lib' dir.
        /^#{Regexp.escape(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))))}/,

        # Users certainly don't care about what test loader is being used
        %r[lib/rake/rake_test_loader.rb], %r[bin/testrb]
      ]

      # Filter the backtrace, removing any reference to files located in
      # BASE_PATH.
      def filter_backtrace(backtrace, prefix=nil)
        paths = ESCAPE_PATHS + [prefix].compact
        backtrace.reject do |line|
          file = line.split(":").first
          paths.any? {|path| File.expand_path(file) =~ path }
        end
      end
    end
  end
end
