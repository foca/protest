module Testicles
  class Runner
    # Set up the test runner. Takes in a Report that will be passed to test
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
        test_case.run(@report)
        @report.on_exit(test_case) if @report.respond_to?(:on_exit)
      end
      @report.on_end if @report.respond_to?(:on_end)
    end
  end
end
