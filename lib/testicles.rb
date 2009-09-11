module Testicles
  class AssertionFailed < StandardError; end
  class Pending < StandardError; end

  def self.report(name, *args)
    @runners.fetch(name).new(*args)
  end

  def self.add_report(name, runner)
    @runners ||= {}
    @runners[name] = runner
  end
end

require "testicles/test_case"
require "testicles/runner"
require "testicles/report"
require "testicles/reports"
require "testicles/reports/progress"
