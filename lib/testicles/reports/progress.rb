module Testicles
  class Reports::Progress < Report
    def initialize(stream=STDOUT)
      @stream = stream
    end

    on :end do |report|
      report.instance_eval do
        puts
        puts
        report_pending_tests unless pendings.empty?
        report_errors unless errors.empty?
        puts summary
        puts running_time
      end
    end

    on :pass do |report, pass|
      report.send(:print, ".")
    end

    on :pending do |report, pending|
      report.send(:print, "P")
    end

    on :failure do |report, failure|
      report.send(:print, "F")
    end

    on :error do |report, error|
      report.send(:print, "E")
    end

    private

      def running_time
        "Ran in #{@time_elapsed} seconds"
      end

      def report_pending_tests
        puts "Pending tests:"
        puts

        pad_indexes = pendings.size.to_s.size
        pendings.each_with_index do |pending, index|
          puts "  #{pad(index+1, pad_indexes)}) #{pending.message}"
          puts indent("on line #{pending.line} of `#{pending.file}'", 6 + pad_indexes)
          puts
        end
      end

      def report_errors
        puts "Failures:"
        puts

        pad_indexes = errors.size.to_s.size
        errors.each_with_index do |error, index|
          puts "  #{pad(index+1, pad_indexes)}) #{error.type}: `#{error.message}' (on line #{error.line} of `#{error.file}')"
          puts indent(error.backtrace[0..2].join("\n"), 6 + pad_indexes)
          puts
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

      def print(*args)
        @stream.print(*args)
      end

      def puts(*args)
        @stream.puts(*args)
      end
  end

  add_report :progress, Reports::Progress
end
