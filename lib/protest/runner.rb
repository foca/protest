module Protest
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
    # of the test as an argument. By passing +true+ as the second argument, you
    # force any exceptions to be re-raied and the test not reported as a pass
    # after it finishes (for global setup/teardown blocks)
    def report(test, running_global_setup_or_teardown=false)
      @report.on_test(Test.new(test)) if @report.respond_to?(:on_test) && !running_global_setup_or_teardown
      test.run(@report)
      @report.on_pass(PassedTest.new(test)) unless running_global_setup_or_teardown
    rescue Pending => e
      @report.on_pending(PendingTest.new(test, e))
    rescue AssertionFailed => e
      @report.on_failure(FailedTest.new(test, e))
    rescue Exception => e
      @report.on_error(ErroredTest.new(test, e))
      raise if running_global_setup_or_teardown
    end
  end
end
