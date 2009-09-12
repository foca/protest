module Testicles
  class Runner
    # Set up the test runner. Takes in a report that will be passed to test
    # cases for reporting.
    def initialize(report)
      @report = report
    end

    # Run a set of test cases, provided as arguments. This will fire relevant
    # events on the runner's report, at the +start+ and +end+ of the test run,
    # and before and after each test case (+enter+ and +exit+.)
    def run(*test_cases)
      @report.on_start if @report.respond_to?(:on_start)
      test_cases.each do |test_case|
        @report.on_enter(test_case) if @report.respond_to?(:on_enter)
        test_case.run(self)
        @report.on_exit(test_case) if @report.respond_to?(:on_exit)
      end
      @report.on_end if @report.respond_to?(:on_end)
    end

    # Run a test and report if it passes, fails, or is pending. Takes the name
    # of the test as an argument. You can avoid reporting a passed test by
    # passing +false+ as a second argument.
    def report(test, report_success=true)
      @report.on_test(Test.new(test)) if @report.respond_to?(:on_test)
      yield
      @report.on_pass(PassedTest.new(test)) if report_success
    rescue Pending => e
      @report.on_pending(PendingTest.new(test, e))
    rescue AssertionFailed => e
      @report.on_failure(FailedTest.new(test, e))
    rescue Exception => e
      @report.on_error(ErroredTest.new(test, e))
    end

    def assert(condition, message) #:nodoc:
      @report.add_assertion
      raise AssertionFailed, message unless condition
    end
  end
end
