require "testicles"

class A < Testicles::TestCase
  setup do
    @foo = 1
  end

  context "nested contexts" do
    setup do
      @bar = 2
    end

    test "run setup blocks from their parents" do
      assert @foo == 1
    end

    test "and run setup and teardown blocks from themselves" do
      assert @bar > @foo
    end
  end

  test "this one passes" do
    assert true
  end

  test "a test" do
    assert false
  end

  test "a pending test"

  test "another pending test" do
    pending "this won't raise"
    raise "foo"
  end

  test "another test" do
    assert @foo > 0, "expected @foo to be greater than 0"
  end

  test "a failing one" do
    assert @foo.zero?, "expected @foo to be 0"
  end

  test "passes again" do
    assert @foo < 10, "expected @foo to less than 10"
  end

  test "kaboom" do
    raise "foo"
  end

  test "passes again" do
    assert(@foo % 2 != 0)
  end

  test "tests don't know anything about the child contexts" do
    assert @bar.nil?
  end
end
