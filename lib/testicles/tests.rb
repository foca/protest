module Testicles
  # Encapsulates the relevant information about a test. Useful for certain
  # reports.
  class Test
    # Name of the test that passed. Useful for certain reports.
    attr_reader :test_name

    def initialize(test_name) #:nodoc:
      @test_name = test_name
    end
  end

  # Mixin for tests that had an error (this could be either a failed assertion,
  # unrescued exceptions, or just a pending tests.)
  module TestWithErrors
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

  # Encapsulate the relevant information for a test that passed.
  class PassedTest < Test
  end

  # Encapsulates the relevant information for a test which failed an
  # assertion.
  class FailedTest < Test
    include TestWithErrors

    def initialize(test_name, error) #:nodoc:
      super(test_name)
      @error = error
    end
  end

  # Encapsulates the relevant information for a test which raised an
  # unrescued exception.
  class ErroredTest < Test
    include TestWithErrors

    def initialize(test_name, error) #:nodoc:
      super(test_name)
      @error = error
    end
  end

  # Encapsulates the relevant information for a test that the user marked as
  # pending.
  class PendingTest < Test
    include TestWithErrors

    # Message passed to TestCase#pending, if any.
    alias_method :pending_message, :error_message

    def initialize(test_name, error) #:nodoc:
      super(test_name)
      @error = error
    end
  end
end
