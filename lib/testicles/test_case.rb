module Testicles
  class TestCase
    def self.run(result)
      tests.each {|test| test.run(result) }
    end

    def self.test(name, &block)
      tests << new(name, &block)
    end

    def self.setup(&block)
      define_method :setup do
        super
        instance_eval(&block)
      end
    end

    def self.teardown(&block)
      define_method :teardown do
        instance_eval(&block)
        super
      end
    end

    attr_reader :test, :name

    def initialize(name, &block)
      @test = block
      @name = name
    end

    def run(result)
      @result = result

      result.report(name) do
        pending if test.nil?

        setup
        instance_eval(&test)
        teardown
      end
    end

    def assert(condition, message="Expected condition to be satisfied, but wasn't")
      @result.on_assertion
      raise AssertionFailed, message unless condition
    end

    def setup
    end

    def teardown
    end

    def pending(message=name)
      raise Pending, message
    end

    def self.tests
      @tests ||= []
    end
    private_class_method :tests
  end
end
