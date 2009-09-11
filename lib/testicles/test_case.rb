module Testicles
  module DSL
    def test(name, &block)
      tests << new(name, &block)
    end

    def setup(&block)
      define_method :setup do
        super
        instance_eval(&block)
      end
    end

    def teardown(&block)
      define_method :teardown do
        instance_eval(&block)
        super
      end
    end

    def pending(name, &block)
      tests << new(name)
    end

    def run(result)
      tests.each {|test| test.run(result) }
    end

    private

      def tests
        @tests ||= []
      end
  end

  class TestCase
    extend DSL

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
  end
end
