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
end
