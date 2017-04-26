require 'active_record'
require 'discordrb'
require 'yaml'
require 'pp'
require './lib/utilities.rb'
require 'test/unit'

# Tests database connections.
class UtilitiesTest < Test::Unit::TestCase
  def test_options_hash
    input = 'id: Test ID, name: Test Name, purpose: Input is correctly split into a hash'
    expected = { id: 'Test ID', name: 'Test Name', purpose: 'Input is correctly split into a hash' }
    assert_equal expected, Utilities::to_options(input)
  end

  def test_specific_options
    clan = 'Toreador'
    covenant = 'Convenant'
    input = { test: 1, clan: clan, covenant: covenant }
    expected = { test: 1, xsplat: clan, ysplat: covenant }

    assert_equal expected, Utilities::specific_options(input)
  end

  def test_specific_array
    input = [:clan, :test, :tribe, :auspice]
    expected = [:xsplat, :test, :ysplat, :xsplat]

    assert_equal expected, Utilities::specific_array(input)
  end
end