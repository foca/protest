module Testicles
  # For each testcase in your suite, this will output the description of the test
  # case (whatever you provide TestCase.context), followed by the name of each test
  # in that context, one per line. For example:
  #
  #     Testicles.context "A user" do
  #       test "has a name" do
  #         ...
  #       end
  #
  #       test "has an email" do
  #         ...
  #       end
  #
  #       context "validations" do
  #         test "ensure the email can't be blank" do
  #           ...
  #         end
  #       end
  #     end
  #
  # Will output, when run with the +:documentation+ report:
  #
  #     A user
  #     - has a name
  #     - has an email
  #
  #     A user validations
  #     - ensure the email can't be blank
  #
  # This is based on the specdoc runner in rspec[http://rspec.info].
  class Reports::Documentation < Report
    include Utils::Summaries
    include Utils::ColorfulOutput

    attr_reader :stream #:nodoc:

    # Set the stream where the report will be written to. STDOUT by default.
    def initialize(stream=STDOUT)
      @stream = stream
    end

    on :enter do |report, context|
      report.puts context.description unless context.tests.empty?
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

    on :exit do |report, context|
      report.puts unless context.tests.empty?
    end

    on :end do |report|
      report.summarize_pending_tests
      report.summarize_errors
      report.summarize_test_totals
    end
  end

  add_report :documentation, Reports::Documentation
end
