module Testicles
  class Reports::Progress < Report
    def initialize(stream=STDOUT)
      @stream = stream
    end

    def on_end
      @stream.puts
      @stream.puts
      report_errors unless errors.empty?
      @stream.puts summary
      @stream.puts running_time
    end

    def on_pass(name)
      super
      @stream.print(".")
    end

    def on_pending(name)
      super
      @stream.print("P")
    end

    def on_failure(name)
      super
      @stream.print("F")
    end

    def on_error(name)
      super
      @stream.print("E")
    end

    private

      def running_time
        "Ran in #{@time_elapsed} seconds"
      end

      def report_errors
        @stream.puts "Failures:"
        @stream.puts

        pad_indexes = errors.size.to_s.size
        errors.each_with_index do |error, index|
          @stream.puts "  #{pad(index+1, pad_indexes)}) #{error.type}: `#{error.message}' (on #{error.line} of `#{error.file}')"
          @stream.puts indent(error.backtrace[0..2].join("\n"), 6 + pad_indexes)
          @stream.puts
        end
      end

      def summary
        "%d test%s, %d assertion%s (%d passed, %d pending, %d failed, %d errored)" % [total_tests,
                                                                                      total_tests == 1 ? "" : "s",
                                                                                      assertions,
                                                                                      assertions == 1 ? "" : "s",
                                                                                      passes.size,
                                                                                      pendings.size,
                                                                                      failures.size,
                                                                                      errors.size]
      end

      def indent(strings, size=2, indent_with=" ")
        Array(strings).map do |str|
          str.to_s.split("\n").map {|s| indent_with * size + s }.join("\n")
        end
      end

      def pad(str, amount)
        " " * (amount - str.to_s.size) + str.to_s
      end
  end

  add_report :progress, Reports::Progress
end
