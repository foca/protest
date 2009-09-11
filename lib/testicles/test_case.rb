module Testicles
  class TestCase
    class << self
      attr_accessor :description
    end

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

    def self.context(description, &block)
      subclass = Class.new(self)
      subclass.class_eval(&block) if block
      subclass.description = "#{self.description} #{description}".strip
      const_set(sanitize_description(description), subclass)
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

    def self.sanitize_description(description)
      "Test#{description.gsub(/\W+/, ' ').strip.gsub(/(^| )(\w)/) { $2.upcase }}".to_sym
    end
    private_class_method :sanitize_description

    def self.inherited(child)
      Testicles.add_test_case(child)
    end
  end
end
