require "testicles"

Testicles.report_with(:documentation)

module TestHelpers
  class IORecorder
    attr_reader :messages

    def initialize
      @messages = []
    end

    def puts(msg=nil)
      @messages << msg
    end

    def print(msg=nil)
      @messages << msg
    end
  end

  def silent_report(type=:progress)
    Testicles.report(type, IORecorder.new)
  end

  def mock_test_case(&block)
    test_case = Testicles.describe(name, &block)
    test_case.description = ""
    nested_contexts = Testicles.send(:available_test_cases).select {|t| t < test_case }

    report = silent_report
    [test_case, *nested_contexts].each do |test_case|
      test_case.run(Testicles::Runner.new(report))
    end
    report
  end

  module Assertions
    def assert_equal(expected, actual, message="<#{expected}> expected, but was <#{actual}>")
      assert(expected == actual, message)
    end
  end
end

class Testicles::TestCase
  include TestHelpers
  include TestHelpers::Assertions
end
