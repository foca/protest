module Testicles
  class TestCase
    # Run all tests in this context. Takes a Report instance in order to
    # provide output.
    def self.run(result)
      tests.each {|test| test.run(result) }
    end

    # Add a test to be run in this context. This method is aliased as +it+ and
    # +should+ for your comfort.
    def self.test(name, &block)
      tests << new(name, &block)
    end

    # Add a setup block to be run before each test in this context. This method
    # is aliased as +before+ for your comfort.
    def self.setup(&block)
      define_method :setup do
        super
        instance_eval(&block)
      end
    end

    # Add a teardown block to be run after each test in this context. This
    # method is aliased as +after+ for your comfort.
    def self.teardown(&block)
      define_method :teardown do
        instance_eval(&block)
        super
      end
    end

    # Define a new test context nested under the current one. All +setup+ and
    # +teardown+ blocks defined on the current context will be inherited by the
    # new context. This method is aliased as +describe+ for your comfort.
    def self.context(description, &block)
      subclass = Class.new(self)
      subclass.class_eval(&block) if block
      subclass.description = "#{self.description} #{description}".strip
      const_set(sanitize_description(description), subclass)
    end

    class << self
      # Fancy name for your test case, reports can use this to give nice,
      # descriptive output when running your tests.
      attr_accessor :description

      alias_method :describe, :context
      alias_method :story,    :context

      alias_method :before,   :setup
      alias_method :after,    :teardown

      alias_method :it,       :test
      alias_method :should,   :test
      alias_method :scenario, :test
    end

    # Initialize a new instance of a single test. This test can be run in
    # isolation by calling TestCase#run.
    def initialize(name, &block)
      @test = block
      @name = name
    end

    # Run a test in isolation. Any +setup+ and +teardown+ blocks defined for
    # this test case will be run as expected.
    #
    # You need to provide a Report instance to handle errors/pending tests/etc.
    #
    # If the test's block is nil, then the test will be marked as pending and
    # nothing will be run.
    def run(result)
      @result = result

      result.report(name) do
        pending if test.nil?

        setup
        instance_eval(&test)
        teardown
      end
    end

    # Ensure a condition is met. This will raise AssertionFailed if the
    # condition isn't met. You can override the default failure message
    # by passing it as an argument.
    def assert(condition, message="Expected condition to be satisfied")
      @result.on_assertion
      raise AssertionFailed, message unless condition
    end

    # Make the test be ignored as pending. You can override the default message
    # that will be sent to the report by passing it as an argument.
    def pending(message="Not Yet Implemented")
      raise Pending, message
    end

    private

    def setup #:nodoc:
    end

    def teardown #:nodoc:
    end

    def test
      @test
    end

    def name
      @name
    end

    def self.tests
      @tests ||= []
    end
    private_class_method :tests

    def self.sanitize_description(description)
      "Test#{description.gsub(/\W+/, ' ').strip.gsub(/(^| )(\w)/) { $2.upcase }}".to_sym
    end
    private_class_method :sanitize_description

    def self.inherited(child)
      Testicles.add_test_case(child)
    end
  end
end
