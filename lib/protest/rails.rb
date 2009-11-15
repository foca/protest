require "protest"
require "test/unit/assertions"
require "action_controller/test_case"

begin
  require "webrat"
rescue LoadError
  $no_webrat = true
end

module Protest
  module Rails
    # Exclude rails' files from the errors
    class Utils::BacktraceFilter
      include ::Rails::BacktraceFilterForTestUnit
    end

    # Wrap all tests in a database transaction.
    #
    # TODO: make this optional somehow (yet enabled by default) so users of
    # other ORMs don't run into problems.
    module TransactionalTests
      def run(*args, &block)
        ActiveRecord::Base.connection.transaction do
          super(*args, &block)
          raise ActiveRecord::Rollback
        end
      end
    end

    # You should inherit from this TestCase in order to get rails' helpers
    # loaded into Protest. These include all the assertions bundled with rails
    # and your tests being wrapped in a transaction.
    class TestCase < ::Protest::TestCase
      include ::Test::Unit::Assertions
      include ActiveSupport::Testing::Assertions
      include TransactionalTests
    end

    class RequestTest < TestCase #:nodoc:
      %w(response selector tag dom routing model).each do |kind|
        include ActionController::Assertions.const_get("#{kind.camelize}Assertions")
      end
    end

    # Make your integration tests inherit from this class, which bundles the
    # integration runner included with rails, and webrat's test methods. You
    # should use webrat for integration tests. Really.
    class IntegrationTest < RequestTest
      include ActionController::Integration::Runner
      include Webrat::Methods unless $no_webrat
    end
  end

  # The preferred way to declare a context (top level) is to use
  # +Protest.describe+ or +Protest.context+, which will ensure you're using
  # rails adapter with the helpers you need.
  def self.context(description, &block)
    Rails::TestCase.context(description, &block)
  end

  # Use +Protest.story+ to declare an integration test for your rails app. Note
  # that the files should still be called 'test/integration/foo_test.rb' if you
  # want the 'test:integration' rake task to pick them up.
  def self.story(description, &block)
    Rails::IntegrationTest.story(description, &block)
  end

  class << self
    alias_method :describe, :context
  end
end
