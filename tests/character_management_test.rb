require 'active_record'
require 'discordrb'
require 'erb'
require 'yaml'
require './lib/character_management.rb'
require 'test/unit'
require 'pp'

# Tests database connections.
class CharacterManagementTest < Test::Unit::TestCase
  def setup
    config = YAML.load(ERB.new(File.read('config/database.yml')).result)['test']
    ActiveRecord::Base.establish_connection(config)
  end

  def teardown
    ActiveRecord::Base.connection.close
  end

  def test_create_character_valid
    identifier = 'CreateTest'
    name = 'Create Test'
    strength = 5
    virtue = 'A virtue'
    input = "#{identifier} name: #{name}, strength: #{strength}, virtue: #{virtue}".split(' ')

    options, character, errors = CharacterManagement::create_character(input)

    assert_equal nil, errors
    assert character
    assert_equal identifier, character.identifier
    assert_equal name, character.name
    assert_equal strength, character.strength
    assert_equal virtue, character.virtue
  end

  def test_create_character_invalid
    identifier = 'CreateTestInvalid'
    input = "#{identifier} name: #{identifier}, invalid_attr: invalid".split(' ')

    options, character, errors = CharacterManagement::create_character(input)

    assert errors
    assert_equal nil, character
  end

  def test_update_character_valid
    identifier = 'UpdateValid'
    name = 'Update Valid'
    strength = 5
    virtue = 'A virtue'
    input = "#{identifier} name: #{name}, strength: #{strength}, virtue: #{virtue}".split(' ')

    character = Character.create(identifier: identifier)
    assert_equal identifier, character.identifier

    id, saved, errors = CharacterManagement::update_character(input)

    assert saved
    assert errors.empty?
    assert_equal identifier, id

    character = Character.where(identifier: identifier).first
    assert_equal identifier, character.identifier
    assert_equal name, character.name
    assert_equal strength, character.strength
    assert_equal virtue, character.virtue
  end

  def test_update_character_invalid
    identifier = 'UpdateInvalid'
    name = 'Update Invalid'
    input = "#{identifier} name: #{name}, invalid_attr: invalid".split(' ')

    character = Character.create(identifier: identifier)
    assert_equal identifier, character.identifier

    id, saved, errors = CharacterManagement::update_character(input)

    assert_equal identifier, id
    refute saved
    assert errors
  end

  def test_parse_args
    identifier = 'Identifier'
    name = 'Name'
    strength = '1'
    intelligence = '2'
    input = "#{identifier} name: #{name}, strength: #{strength}, intelligence: #{intelligence}".split(' ')
    expected = { name: name, strength: strength, intelligence: intelligence }

    id, options = CharacterManagement::parse_args(input)

    assert_equal identifier, id
    assert_equal expected, options
  end
end
