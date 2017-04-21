require 'discordrb'
require './lib/rng.rb'
require 'test/unit'

# Test base bot behavior.
class RNGTest < Test::Unit::TestCase
  def test_random
    min = 1
    max = 10

    (1..50).each do
      result = RNG::random_command(nil, nil)
      assert (min..max).include? result[0]
      assert_equal min, result[1]
      assert_equal max, result[2]
    end
  end

  def test_random_max
    min = 1
    max = 10

    (1..50).each do
      result = RNG::random_command(nil, max)
      assert (1..max).include? result[0]
      assert_equal min, result[1]
      assert_equal max, result[2]
    end
  end

  def test_random_min_max
    min = 5
    max = 10

    (1..50).each do
      result = RNG::random_command(min, max)
      assert (min..max).include? result[0]
      assert_equal min, result[1]
      assert_equal max, result[2]
    end
  end

  def test_roll_nds_no_n
    sides = 20
    expected_length = 1

    result = RNG::roll(["d#{sides}"], [])
    assert_equal expected_length, result[0].length
  end

  def test_roll_nds_number
    number = 20
    result = RNG::roll(["#{number}d20"], [])
    assert_equal number, result[0].length
  end

  def test_roll_nds_sides
    number = 1
    sides = 5

    (1..50).each do
      result = RNG::roll(["#{number}d#{sides}"], [])
      assert (1..sides).include? result[0][0]
    end
  end

  def test_roll_nds_offset_positive
    number = 1
    sides = 5
    offset = '+3'

    (1..50).each do
      result = RNG::roll(["#{number}d#{sides}#{offset}"], [])
      assert (1..sides).include? result[0][0]
      assert_equal offset, result[1]
    end
  end

  def test_roll_nds_offset_negative
    number = 1
    sides = 5
    offset = '-3'

    (1..50).each do
      result = RNG::roll(["#{number}d#{sides}#{offset}"], [])
      assert (1..sides).include? result[0][0]
      assert_equal offset, result[1]
    end
  end

  def test_roll_nds_seed
    number = 5
    sides = 10
    expected = [4, 7, 6, 5, 9]

    srand 1234
    result = RNG::roll(["#{number}d#{sides}"], [])
    assert_equal expected, result[0]
  end

  def test_roll_nds_explode_no_10s
    number = 5
    sides = 10
    expected_length = [4, 7, 6, 5, 9].length

    srand 1234
    result = RNG::roll(["#{number}d#{sides}"], [])
    assert_equal expected_length, result[0].length
  end

  def test_roll_nds_explode_10s
    number = 5
    sides = 10
    expected = [3, 6, 2, 5, 10, 6]

    srand 12345
    result = RNG::roll(["#{number}d#{sides}"], ['--explode'])
    assert_equal expected, result[0]
  end

  def test_roll_nds_explode_10s_shorthand
    number = 5
    sides = 10
    expected = [3, 6, 2, 5, 10, 6]

    srand 12345
    result = RNG::roll(["#{number}d#{sides}"], ['--e'])
    assert_equal expected, result[0]
  end

  def test_roll_min_max
    min = 1
    max = 10

    (1..50).each do
      result = RNG::roll(["#{min}-#{max}"], [])
      assert (min..max).include? result[0][0]
    end
  end

  def test_roll_min_max_orphan
    max = 10

    (1..50).each do
      result = RNG::roll(["#{max}"], [])
      assert (1..max).include? result[0][0]
    end
  end

  def test_roll_min_max_offset_positive
    min = 1
    max = 10
    offset = '+5'

    (1..50).each do
      result = RNG::roll(["#{min}-#{max}#{offset}"], [])
      assert (min..max).include? result[0][0]
      assert_equal offset, result[1]
    end
  end

  def test_roll_min_max_offset_negative
    min = 1
    max = 10
    offset = '-7'

    (1..50).each do
      result = RNG::roll(["#{min}-#{max}#{offset}"], [])
      assert (min..max).include? result[0][0]
      assert_equal offset, result[1]
    end
  end
end
