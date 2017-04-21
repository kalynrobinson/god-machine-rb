require 'active_record'
require 'yaml'
require 'pp'
require_relative '../../lib/models/character'
require 'test/unit'

# Tests database connections.
class ActiveRecordTest < Test::Unit::TestCase
  def setup
    config = YAML.load_file('config/database.yml')
    ActiveRecord::Base.establish_connection(config['test'])
  end

  def test_character_creation
    character = Character.new(identifier: 'Saves Correctly')
    assert character.save, 'Character is not saving correctly.'
  end

  def test_valid_character
    character = Character.new(identifier: 'Validates Correctly')
    assert character.valid?, 'Character with valid identifier is incorrectly interpreted as invalid.'
  end

  def test_invalid_identifier_presence
    character = Character.new
    refute character.valid?, 'Character with no identifier is incorrectly interpreted as valid.'
  end

  def test_invalid_identifier_uniqueness
    character1 = Character.new(identifier: 'Duplicate')
    assert character1.save

    character2 = Character.new(identifier: 'Duplicate')
    refute character2.valid?, 'Character with duplicate identifier is incorrectly interpreted as valid.'
  end

  def test_find_character
    id = 'Finding'
    Character.create(identifier: id)
    assert Character.find_by(identifier: id)
  end

  def test_invalid_numericality
    character = Character.new(identifier: 'Invalid Numericality')
    assert character.valid?

    character.stamina = 'Invalid'
    refute character.valid?
  end

  def test_valid_numericality
    character = Character.new(identifier: 'Valid Numericality')
    assert character.valid?

    character.stamina = 5
    assert character.valid?
  end
end
