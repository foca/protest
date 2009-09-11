module Testicles
  class Runner
    def initialize(report)
      @report = report
    end

    def run(*test_cases)
      @report.on_start if @report.respond_to?(:on_start)
      started_at = Time.now
      test_cases.each do |test_case|
        @report.on_enter(test_case) if @report.respond_to?(:on_enter)
        test_case.run(@report)
        @report.on_exit(test_case) if @report.respond_to?(:on_exit)
      end
      @report.time_elapsed = Time.now - started_at
      @report.on_end if @report.respond_to?(:on_end)
    end
  end
end
