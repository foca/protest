module Protest
  module Utils
    # Mixin that provides summaries for your text based test runs.
    module Summaries
      # Call on +:end+ to output the amount of tests (passed, pending, failed
      # and errored), the amount of assertions, and the time elapsed.
      #
      # For example:
      #
      #     on :end do |report|
      #       report.puts
      #       report.summarize_test_totals
      #     end
      #
      # This relies on the public Report API, and on the presence of a #puts
      # method to write to whatever source you are writing your report.
      def summarize_test_totals
        puts test_totals
        puts running_time
      end

      # Call on +:end+ to print a list of pending tests, including file and line
      # number where the call to TestCase#pending+ was made.
      #
      # It will not output anything if there weren't any pending tests.
      #
      # For example:
      #
      #     on :end do |report|
      #       report.puts
      #       report.summarize_pending_tests
      #     end
      #
      # This relies on the public Report API, and on the presence of a #puts
      # method to write to whatever source you are writing your report.
      def summarize_pending_tests
        return if pendings.empty?

        puts "Pending tests:"
        puts

        pad_indexes = pendings.size.to_s.size
        pendings.each_with_index do |pending, index|
          puts "  #{pad(index+1, pad_indexes)}) #{pending.test_name} (#{pending.pending_message})", :pending
          puts indent("On line #{pending.line} of `#{pending.file}'", 6 + pad_indexes), :pending
          puts
        end
      end

      # Call on +:end+ to print a list of failures (failed assertions) and errors
      # (unrescued exceptions), including file and line number where the test
      # failed, and a short backtrace.
      #
      # It will not output anything if there weren't any pending tests.
      #
      # For example:
      #
      #     on :end do |report|
      #       report.puts
      #       report.summarize_pending_tests
      #     end
      #
      # This relies on the public Report API, and on the presence of a #puts
      # method to write to whatever source you are writing your report.
      def summarize_errors
        return if failures_and_errors.empty?

        puts "Failures:"
        puts

        pad_indexes = failures_and_errors.size.to_s.size
        failures_and_errors.each_with_index do |error, index|
          colorize_as = ErroredTest === error ? :errored : :failed
          puts "  #{pad(index+1, pad_indexes)}) #{test_type(error)}: `#{error.test_name}' (on line #{error.line} of `#{error.file}')", colorize_as
          puts indent("With `#{error.error_message}'", 6 + pad_indexes), colorize_as
          indent(error.backtrace[0..2], 6 + pad_indexes).each {|backtrace| puts backtrace, colorize_as }
          puts
        end
      end

      private

        def running_time
          "Ran in #{time_elapsed} seconds"
        end

        def test_totals
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

        def test_type(test)
          case test # order is important since ErroredTest < FailedTest
          when ErroredTest; "Error"
          when FailedTest;  "Failure"
          end
        end
    end
  end
end
