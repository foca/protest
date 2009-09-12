module Testicles
  class Report
    # Define an event handler for your report. The different events fired in a
    # report's life cycle are:
    #
    # :start::     Fired by the runner when starting the whole test suite.
    # :enter::     Fired by the runner when starting a particular test case. It
    #              will get the test case as an argument.
    # :test::      Fired by a test before it starts running. It will get the
    #              instance of TestCase for the given test as an argument.
    # :assertion:: Fired by a test each time an assertion is run.
    # :pass::      Fired by a test after it runs successfully without errors.
    #              It will get an instance of PassedTest as an argument.
    # :pending::   Fired by a test which doesn't provide a test block or which
    #              calls TestCase#pending. It will get an instance of
    #              PendingTest as an argument.
    # :failure::   Fired by a test in which an assertion failed. It will get an
    #              instance of FailedTest as an argument.
    # :error::     Fired by a test where an uncaught exception was found. It
    #              will get an instance of ErroredTest as an argument.
    # :exit::      Fired by the runner each time a test case finishes. It will
    #              take the test case as an argument.
    # :end::       Fired by the runner at the end of the whole test suite.
    #
    # The event handler will receive the report as a first argument, plus any
    # arguments documented above (depending on the event). It will also ensure
    # that any handler for the same event declared on an ancestor class is run.
    def self.on(event, &block)
      define_method(:"on_#{event}") do |*args|
        begin
          super(*args)
        rescue NoMethodError
        end

        block.call(self, *args)
      end
    end

    on :start do |report|
      report.instance_eval { @started_at = Time.now }
    end

    on :pass do |report, passed_test|
      report.passes << passed_test
    end

    on :pending do |report, pending_test|
      report.pendings << pending_test
    end

    on :failure do |report, failed_test|
      report.failures << failed_test
      report.failures_and_errors << failed_test
    end

    on :error do |report, errored_test|
      report.errors << errored_test
      report.failures_and_errors << errored_test
    end

    on :assertion do |report|
      report.add_assertion
    end

    # List all the tests (as PendingTest instances) that were pending.
    def pendings
      @pendings ||= []
    end

    # List all the tests (as PassedTest instances) that passed.
    def passes
      @passes ||= []
    end

    # List all the tests (as FailedTest instances) that failed an assertion.
    def failures
      @failures ||= []
    end

    # List all the tests (as ErroredTest instances) that raised an unrescued
    # exception.
    def errors
      @errors ||= []
    end

    # Aggregated and ordered list of tests that either failed an assertion or
    # raised an unrescued exception. Useful for displaying back to the user.
    def failures_and_errors
      @failures_and_errors ||= []
    end

    # Log an assertion was run (whether it succeeded or failed.)
    def add_assertion
      @assertions ||= 0
      @assertions += 1
    end

    # Number of assertions run during the report.
    def assertions
      @assertions || 0
    end

    # Amount ot tests run (whether passed, pending, failed, or errored.)
    def total_tests
      passes.size + failures.size + errors.size + pendings.size
    end

    # Seconds taken since the test suite started running
    def time_elapsed
      Time.now - @started_at
    end
  end

  # Mixin that provides colorful output to your console based reports. This uses
  # bash's escape sequences, so it won't work on windows.
  #
  # TODO: Make this work on windows with ansicolor or whatever the gem is named
  module ColorfulOutput
    # Returns a hash with the color values for different states. Override this
    # method safely to change the output colors. The defaults are:
    #
    # :passed::  Light green
    # :pending:: Light yellow
    # :errored:: Light purple
    # :failed::  Light red
    #
    # See http://www.hypexr.org/bash_tutorial.php#colors for a description of
    # Bash color codes.
    def self.colors
      { :passed => "1;32",
        :pending => "1;33",
        :errored => "1;35",
        :failed => "1;31" }
    end

    class << self
      # Whether to use colors in the output or not. The default is +true+.
      attr_accessor :colorize
    end

    self.colorize = true

    # Print the string followed by a newline to whatever IO stream is defined in
    # the method #stream using the correct color depending on the state passed.
    def puts(string=nil, state=:normal)
      if string.nil? # calling IO#puts with nil is not the same as with no args
        stream.puts
      else
        stream.puts colorize(string, state)
      end
    end

    # Print the string to whatever IO stream is defined in the method #stream
    # using the correct color depending on the state passed.
    def print(string=nil, state=:normal)
      if string.nil? # calling IO#puts with nil is not the same as with no args
        stream.print
      else
        stream.print colorize(string, state)
      end
    end

    private

      def colorize(string, state)
        if state == :normal || !ColorfulOutput.colorize
          string
        else
          "\033[#{color_for_state(state)}m#{string}\033[0m"
        end
      end

      def color_for_state(state)
        ColorfulOutput.colors.fetch(state)
      end
  end

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
