module Testicles
  # The +:progress+ report will output a +.+ for each passed test in the suite,
  # a +P+ for each pending test, an +F+ for each test that failed an assertion,
  # and an +E+ for each test that raised an unrescued exception.
  #
  # At the end of the suite it will output a list of all pending tests, with
  # files and line numbers, and after that a list of all failures and errors,
  # which also contains the first 3 lines of the backtrace for each.
  class Reports::Progress < Report
    include Utils::Summaries
    include Utils::ColorfulOutput

    attr_reader :stream #:nodoc:

    # Set the stream where the report will be written to. STDOUT by default.
    def initialize(stream=STDOUT)
      @stream = stream
    end

    on :end do |report|
      report.puts
      report.puts
      report.summarize_pending_tests
      report.summarize_errors
      report.summarize_test_totals
    end

    on :pass do |report, pass|
      report.print ".", :passed
    end

    on :pending do |report, pending|
      report.print "P", :pending
    end

    on :failure do |report, failure|
      report.print "F", :failed
    end

    on :error do |report, error|
      report.print "E", :errored
    end
  end

  add_report :progress, Reports::Progress
end
