module Testicles
  # Exception raised when an assertion fails. See TestCase#assert
  class AssertionFailed < StandardError; end

  # Exception raised to mark a test as pending. See TestCase#pending
  class Pending < StandardError; end

  # Register a new Report. This will make your report available to Testicles,
  # allowing you to run your tests through this report. For example
  #
  #     module Testicles
  #       class Reports::MyAwesomeReport < Report
  #       end
  #
  #       add_report :awesomesauce, MyAwesomeReport
  #     end
  #
  # See Testicles.report_with to see how to select which report will be used.
  def self.add_report(name, report)
    available_reports[name] = report
  end

  # Register a test case to be run with Testicles. This is done automatically
  # whenever you subclass Testicles::TestCase, so you probably shouldn't pay
  # much attention to this method.
  def self.add_test_case(test_case)
    available_test_cases << test_case
  end

  # Set to +false+ to avoid running tests +at_exit+. Default is +true+.
  def self.autorun=(flag)
    @autorun = flag
  end

  # Checks to see if tests should be run +at_exit+ or not. Default is +true+.
  # See Testicles.autorun=
  def self.autorun?
    !!@autorun
  end

  # Run all registered test cases through the selected report. You can pass
  # arguments to the Report constructor here.
  #
  # See Testicles.add_test_case and Testicles.report_with
  def self.run_all_tests!(*report_args)
    Runner.new(@report).run(*available_test_cases)
  end

  # Select the name of the Report to use when running tests. See
  # Testicles.add_report for more information on registering a report.
  #
  # Any extra arguments will be forwarded to the report's #initialize method.
  #
  # The default report is Testicles::Reports::Progress
  def self.report_with(name, *report_args)
    @report = report(name, *report_args)
  end

  # Load a report by name, initializing it with the extra arguments provided.
  # If the given +name+ doesn't match a report registered via
  # Testicles.add_report then the method will raise IndexError.
  def self.report(name, *report_args)
    available_reports.fetch(name).new(*report_args)
  end

  def self.available_test_cases
    @test_cases ||= []
  end
  private_class_method :available_test_cases

  def self.available_reports
    @available_reports ||= {}
  end
  private_class_method :available_reports
end

require "testicles/utils"
require "testicles/utils/summaries"
require "testicles/utils/colorful_output"
require "testicles/test_case"
require "testicles/tests"
require "testicles/runner"
require "testicles/report"
require "testicles/reports"
require "testicles/reports/progress"
require "testicles/reports/documentation"

Testicles.autorun = true
Testicles.report_with(:progress)

at_exit do
  Testicles.run_all_tests! if Testicles.autorun?
end
