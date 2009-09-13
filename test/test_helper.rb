require "testicles"

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
end

class Testicles::TestCase
  include TestHelpers
end
