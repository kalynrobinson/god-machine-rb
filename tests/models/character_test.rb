require 'active_record'
require 'erb'
require 'yaml'
require_relative '../../lib/models/character'
require './lib/utilities.rb'
require 'test/unit'

# Tests database connections.
class CharacterTest < Test::Unit::TestCase
  def setup
    config = YAML.load(ERB.new(File.read('config/database.yml')).result)['test']
    ActiveRecord::Base.establish_connection(config)
  end

  def teardown
    ActiveRecord::Base.connection.close
  end

  def test_character_creation
    character = Character.new(identifier: 'SavesCorrectly')
    assert character.save, 'Character is not saving correctly.'
  end

  def test_valid_character
    character = Character.new(identifier: 'ValidatesCorrectly')
    assert character.valid?, 'Character with valid identifier is incorrectly interpreted as invalid.'
  end

  def test_invalid_id_presence
    character = Character.new
    refute character.valid?, 'Character with no identifier is incorrectly interpreted as valid.'
  end

  def test_invalid_id_uniqueness
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
    character = Character.new(identifier: 'InvalidNumericality')
    assert character.valid?

    character.stamina = 'Invalid'
    refute character.valid?
  end

  def test_valid_numericality
    character = Character.new(identifier: 'ValidNumericality')
    assert character.valid?

    character.stamina = 5
    assert character.valid?
  end

  def test_creation_options
    identifier = 'OptionsTest'
    name = 'This is a test'
    stamina = 5

    input = "identifier: #{identifier}, name: #{name}, stamina: #{stamina}"
    options = Utilities::to_options(input)

    character = Character.new(options)

    assert_equal identifier, character.identifier
    assert_equal name, character.name
    assert_equal stamina, character.stamina
    assert character.save
  end
end
