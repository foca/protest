module Protest
  # Define a top level test context where to define tests. This works exactly
  # the same as subclassing TestCase explicitly.
  #
  #     Protest.context "A user" do
  #       ...
  #     end
  #
  # is just syntax sugar to write:
  #
  #     class TestUser < Protest::TestCase
  #       self.description = "A user"
  #       ...
  #     end
  def self.context(description, &block)
    TestCase.context(description, &block)
  end

  class << self
    alias_method :describe,   :context
    alias_method :story,      :context
  end

  # A TestCase defines a suite of related tests. You can further categorize
  # your tests by declaring nested contexts inside the class. See
  # TestCase.context.
  class TestCase
    begin
      require "test/unit/assertions"
      include Test::Unit::Assertions
    rescue LoadError
    end

    # Run all tests in this context. Takes a Report instance in order to
    # provide output.
    def self.run(runner)
      runner.report(TestWrapper.new(:setup, self), true)
      tests.each {|test| runner.report(test, false) }
      runner.report(TestWrapper.new(:teardown, self), true)
    rescue Exception => e
      # If any exception bubbles up here, then it means it was during the
      # global setup/teardown blocks, so let's just skip the rest of this
      # context.
      return
    end

    # Tests added to this context.
    def self.tests
      @tests ||= []
    end

    # Add a test to be run in this context. This method is aliased as +it+ and
    # +should+ for your comfort.
    def self.test(name, &block)
      tests << new(name, caller.at(0), &block)
    end

    # Add a setup block to be run before each test in this context. This method
    # is aliased as +before+ for your comfort.
    def self.setup(&block)
      define_method :setup do
        super()
        instance_eval(&block)
      end
    end

    # Add a +setup+ block that will be run *once* for the entire test case,
    # before the first test is run.
    #
    # Keep in mind that while +setup+ blocks are evaluated on the context of the
    # test, and thus you can share state between them, your tests will not be
    # able to access instance variables set in a +global_setup+ block.
    #
    # This is usually not needed (and generally using it is a code smell, since
    # you could make a test dependent on the state of other tests, which is a
    # huge problem), but it comes in handy when you need to do expensive
    # operations in your test setup/teardown and the tests won't modify the
    # state set on this operations. For example, creating large amount of
    # records in a database or filesystem, when your tests will only read these
    # records.
    def self.global_setup(&block)
      (class << self; self; end).class_eval do
        define_method :do_global_setup do
          super()
          instance_eval(&block)
        end
      end
    end

    # Add a teardown block to be run after each test in this context. This
    # method is aliased as +after+ for your comfort.
    def self.teardown(&block)
      define_method :teardown do
        instance_eval(&block)
        super()
      end
    end

    # Add a +teardown+ block that will be run *once* for the entire test case,
    # after the last test is run.
    #
    # Keep in mind that while +teardown+ blocks are evaluated on the context of
    # the test, and thus you can share state between the tests and the
    # teardown blocks, you will not be able to access instance variables set in
    # a test from your +global_teardown+ block.
    #
    # See TestCase.global_setup for a discussion on why these methods are best
    # avoided unless you really need them and use them carefully.
    def self.global_teardown(&block)
      (class << self; self; end).class_eval do
        define_method :do_global_teardown do
          instance_eval(&block)
          super()
        end
      end
    end

    # Define a new test context nested under the current one. All +setup+ and
    # +teardown+ blocks defined on the current context will be inherited by the
    # new context. This method is aliased as +describe+ for your comfort.
    def self.context(description, &block)
      subclass = Class.new(self)
      subclass.class_eval(&block) if block
      subclass.description = description
      const_set(sanitize_description(description), subclass)
    end

    class << self
      # Fancy name for your test case, reports can use this to give nice,
      # descriptive output when running your tests.
      attr_accessor :description

      alias_method :describe,   :context
      alias_method :story,      :context

      alias_method :before,     :setup
      alias_method :after,      :teardown

      alias_method :before_all, :global_setup
      alias_method :after_all,  :global_setup

      alias_method :it,         :test
      alias_method :should,     :test
      alias_method :scenario,   :test
    end

    # Initialize a new instance of a single test. This test can be run in
    # isolation by calling TestCase#run.
    def initialize(name, location, &block)
      @test = block
      @location = location
      @name = name
    end

    # Run a test in isolation. Any +setup+ and +teardown+ blocks defined for
    # this test case will be run as expected.
    #
    # You need to provide a Runner instance to handle errors/pending tests/etc.
    #
    # If the test's block is nil, then the test will be marked as pending and
    # nothing will be run.
    def run(report)
      @report = report
      pending if test.nil?

      setup
      instance_eval(&test)
      teardown
      @report = nil
    end

    # Ensure a condition is met. This will raise AssertionFailed if the
    # condition isn't met. You can override the default failure message
    # by passing it as an argument.
    def assert(condition, message="Expected condition to be satisfied")
      @report.add_assertion
      raise AssertionFailed, message unless condition
    end

    # Provided for Test::Unit compatibility, this lets you include
    # Test::Unit::Assertions and everything works seamlessly.
    def assert_block(message="Expected condition to be satisified") #:nodoc:
      assert(yield, message)
    end

    # Make the test be ignored as pending. You can override the default message
    # that will be sent to the report by passing it as an argument.
    def pending(message="Not Yet Implemented")
      raise Pending, message, [@location, *caller].uniq
    end

    # Name of the test
    def name
      @name
    end

    private

    def setup #:nodoc:
    end

    def teardown #:nodoc:
    end

    def test
      @test
    end

    def self.sanitize_description(description)
      "Test#{description.gsub(/\W+/, ' ').strip.gsub(/(^| )(\w)/) { $2.upcase }}".to_sym
    end
    private_class_method :sanitize_description

    def self.do_global_setup
    end
    private_class_method :do_global_setup

    def self.do_global_teardown
    end
    private_class_method :do_global_teardown

    def self.description #:nodoc:
      parent = ancestors[1..-1].detect {|a| a < Protest::TestCase }
      "#{parent.description rescue nil} #{@description}".strip
    end

    def self.inherited(child)
      Protest.add_test_case(child)
    end

    # Provides the TestCase API for global setup/teardown blocks, so they can be
    # "faked" as tests into the reporter (they aren't counted towards the total
    # number of tests but they could count towards the number of failures/errors.)
    class TestWrapper #:nodoc:
      attr_reader :name

      def initialize(type, test_case)
        @type = type
        @test = test_case
        @name = "Global #{@type} for #{test_case.description}"
      end

      def run(report)
        @test.send("do_global_#{@type}")
      end
    end
  end
end
