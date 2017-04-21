require 'active_record'
require 'erb'
require 'yaml'
require_relative '../lib/models/character'
require 'test/unit'

# Tests database connections.
class ActiveRecordTest < Test::Unit::TestCase
  def test_successful_connection
    config = YAML.load(ERB.new(File.read('config/database.yml')).result)['test']
    ActiveRecord::Base.establish_connection(config)

    assert_nothing_raised (ActiveRecord::NoDatabaseError) { Character.first }
  end

  def test_no_database
    config = YAML.load(ERB.new(File.read('tests/fixtures/database.yml')).result)['no_database']
    ActiveRecord::Base.establish_connection(config)

    assert_raise (ActiveRecord::NoDatabaseError) { Character.first }
  end

  def test_unsuccessful_authentication
    config = YAML.load(ERB.new(File.read('tests/fixtures/database.yml')).result)['bad_authentication']
    ActiveRecord::Base.establish_connection(config)

    assert_raise (PG::ConnectionBad) { Character.first }
  end
end
