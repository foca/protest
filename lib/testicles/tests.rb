module Testicles
  # Encapsulate the relevant information for a test that passed.
  class PassedTest
    # Name of the test that passed. Useful for certain reports.
    attr_reader :test_name

    def initialize(test_name) #:nodoc:
      @test_name = test_name
    end
  end

  # Encapsulates the relevant information for a test which failed an
  # assertion.
  class FailedTest < PassedTest
    def initialize(test_name, error) #:nodoc:
      super(test_name)
      @error = error
    end

    # Message with which it failed the assertion
    def error_message
      @error.message
    end

    # Line of the file where the assertion failed
    def line
      backtrace.first.split(":")[1]
    end

    # File where the assertion failed
    def file
      backtrace.first.split(":")[0]
    end

    # Backtrace of the assertion
    def backtrace
      @error.backtrace
    end
  end

  # Encapsulates the relevant information for a test which raised an
  # unrescued exception.
  class ErroredTest < FailedTest
  end

  # Encapsulates the relevant information for a test that the user marked as
  # pending.
  class PendingTest < FailedTest
    # Message passed to TestCase#pending, if any.
    alias_method :pending_message, :error_message
  end
end
