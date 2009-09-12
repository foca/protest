module Testicles
  class Reports::Documentation < Report
    include Summaries
    include ColorfulOutput

    attr_reader :stream #:nodoc:

    # Set the stream where the report will be written to. STDOUT by default.
    def initialize(stream=STDOUT)
      @stream = stream
    end

    on :enter do |report, context|
      report.puts context.description
    end

    on :pass do |report, passed_test|
      report.puts "- #{passed_test.test_name}", :passed
    end

    on :failure do |report, failed_test|
      position = report.failures_and_errors.index(failed_test) + 1
      report.puts "- #{failed_test.test_name} (#{position})", :failed
    end

    on :error do |report, errored_test|
      position = report.failures_and_errors.index(errored_test) + 1
      report.puts "- #{errored_test.test_name} (#{position})", :errored
    end

    on :pending do |report, pending_test|
      report.puts "- #{pending_test.test_name} (#{pending_test.pending_message})", :pending
    end

    on :exit do |report, test_case|
      report.puts
    end

    on :end do |report|
      report.summarize_pending_tests
      report.summarize_errors
      report.summarize_test_totals
    end
  end

  add_report :documentation, Reports::Documentation
end
