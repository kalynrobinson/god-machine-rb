require "./lib/god_machine_test.rb"
require "test/unit"

class GodMachineTest < Test::Unit::TestCase

  def test_sample
    assert_equal(4, 2 + 2)
  end

  def test_class_method
    assert_equal(5, NAME.foo(3,2))
  end

  def test_instance_method
    name = NAME.new
    assert_equal(6, name.bar(3,2))
  end

end
