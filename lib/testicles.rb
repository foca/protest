module Testicles
  class AssertionFailed < StandardError; end
  class Pending < StandardError; end

  def self.add_report(name, runner)
    available_reports[name] = runner
  end

  def self.add_test_case(test_case)
    available_test_cases << test_case
  end

  def self.autorun=(flag)
    @autorun = flag
  end

  def self.autorun?
    !!@autorun
  end

  def self.run_all_tests!(*report_args)
    report = available_reports.fetch(@report).new(*report_args)
    Runner.new(report).run(*available_test_cases)
  end

  def self.report_with(name)
    @report = name
  end

  self.autorun = true
  self.report_with(:progress)

  def self.available_test_cases
    @test_cases ||= []
  end
  private_class_method :available_test_cases

  def self.available_reports
    @available_reports ||= {}
  end
  private_class_method :available_reports
end

require "testicles/test_case"
require "testicles/runner"
require "testicles/report"
require "testicles/reports"
require "testicles/reports/progress"

at_exit do
  Testicles.run_all_tests! if Testicles.autorun?
end
