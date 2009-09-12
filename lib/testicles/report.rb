module Testicles
  class Report
    # Seconds taken to run the test suite.
    #
    # TODO: this doesn't belong here, it's being set from within the test
    # runner. But we need the value here.
    attr_accessor :time_elapsed

    # Define an event handler for your report. The different events fired in a
    # report's life cycle are:
    #
    # :start::     Fired by the runner when starting the whole test suite.
    # :enter::     Fired by the runner when starting a particular test case. It
    #              will get the test case as an argument.
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

    # Run a test and report if it passes, fails, or is pending. Takes the name
    # of the test as an argument. You can avoid reporting a passed test by
    # passing +false+ as a second argument.
    def report(name, report_success=true)
      yield
      on_pass(PassedTest.new(name)) if report_success
    rescue Pending => e
      on_pending(PendingTest.new(name, e))
    rescue AssertionFailed => e
      on_failure(FailedTest.new(name, e))
    rescue Exception => e
      on_error(ErroredTest.new(name, e))
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

    # Encapsulate the relevant information for a test that passed.
    class PassedTest
      # Name of the test that passed. Useful for certain reports.
      attr_reader :test_name

      def initialize(test_name) #:nodoc:
        @test_name = test_name
      end
    end

    # Encapsulates the relevant information for a test which failed an
    # assertion.
    class FailedTest < PassedTest
      def initialize(test_name, error) #:nodoc:
        super(test_name)
        @error = error
      end

      # Message with which it failed the assertion
      def error_message
        @error.message
      end

      # Line of the file where the assertion failed
      def line
        backtrace.first.split(":")[1]
      end

      # File where the assertion failed
      def file
        backtrace.first.split(":")[0]
      end

      # Backtrace of the assertion
      def backtrace
        @error.backtrace
      end
    end

    # Encapsulates the relevant information for a test which raised an
    # unrescued exception.
    class ErroredTest < FailedTest
    end

    # Encapsulates the relevant information for a test that the user marked as
    # pending.
    class PendingTest < FailedTest
      # Message passed to TestCase#pending, if any.
      alias_method :pending_message, :error_message
    end
  end
end
