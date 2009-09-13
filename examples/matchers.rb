require "testicles"

class Object
  def should(expectation)
    expectation.match?(self)
  end
end

module Matchers
  class EqualityMatcher
    def initialize(expected, test_case)
      @expected = expected
      @test_case = test_case
    end

    def match?(actual)
      @test_case.assert(@expected == actual)
    end
  end

  def equal(expected)
    EqualityMatcher.new(expected, self)
  end
end

Testicles.describe("A number") do
  include Matchers

  it "equals itself" do
    1.should equal(1)
  end
end
