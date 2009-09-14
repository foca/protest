module Testicles
  module Utils
    # Small utility object to filter an error's backtrace and remove any mention
    # of Testicle's own files.
    module BacktraceFilter
      # Path to the library's 'lib' dir.
      BASE_PATH = /^#{Regexp.escape(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__)))))}/

      # Filter the backtrace, removing any reference to files located in
      # BASE_PATH.
      def self.filter(backtrace)
        backtrace.reject do |line|
          file = line.split(":").first
          File.expand_path(file) =~ BASE_PATH
        end
      end
    end
  end
end
