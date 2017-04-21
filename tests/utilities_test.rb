require 'active_record'
require 'yaml'
require 'pp'
require './lib/utilities.rb'
require 'test/unit'

# Tests database connections.
class ActiveRecordTest < Test::Unit::TestCase
  def test_options_hash
    input = 'id: Test ID, name: Test Name, purpose: Input is correctly split into a hash'
    expected = { id: 'Test ID', name: 'Test Name', purpose: 'Input is correctly split into a hash' }
    assert_equal expected, Utilities::to_options(input)
  end
end