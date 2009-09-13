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
