module Testicles
  class Report
    attr_accessor :time_elapsed

    def report(name)
      yield
      on_pass(name)
    rescue Pending => e
      on_pending(e)
    rescue AssertionFailed => e
      on_failure(e)
    rescue Exception => e
      on_error(e)
    end

    def on_pass(name)
      passes << PassedTest.new(name)
    end

    def on_pending(error)
      pendings << PendingTest.new(error)
    end

    def on_failure(error)
      error = FailedTest.new(error)
      failures << error
      errors << error
    end

    def on_error(error)
      errors << ErroredTest.new(error)
    end

    def on_assertion
      @assertions ||= 0
      @assertions += 1
    end

    def pendings
      @pendings ||= []
    end

    def passes
      @passes ||= []
    end

    def failures
      @failures ||= []
    end

    def errors
      @errors ||= []
    end

    def add_assertion
      @assertions ||= 0
      @assertions += 1
    end

    def assertions
      @assertions || 0
    end

    def total_tests
      passes.size + failures.size + errors.size + pendings.size
    end

    class PassedTest < Struct.new(:message)
    end

    class FailedTest < PassedTest
      def initialize(error)
        super(error.message)
        @error = error
      end

      def type
        "Failure"
      end

      def line
        backtrace.first.split(":")[1]
      end

      def file
        backtrace.first.split(":")[0]
      end

      def backtrace
        @error.backtrace
      end
    end

    class ErroredTest < FailedTest
      def type
        "Error"
      end
    end

    class PendingTest < FailedTest
      def type
        "Pending"
      end
    end
  end
end
