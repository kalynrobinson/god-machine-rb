# Handles character-related commands, such as create, update, and inspect.
module CharacterManagement
  extend Discordrb::Commands::CommandContainer

  require_relative 'models/character'

  COMMANDS_CONFIG = YAML.load_file('./config/commands.yaml')

  # Generates a random number between 0 and 1, 0 and max or min and max.
  command(:create, min_args: 1,
          description: COMMANDS_CONFIG['create']['description'],
          usage: COMMANDS_CONFIG['create']['description'],
          parameters: COMMANDS_CONFIG['create']['parameters']) do |_event, *args|

    options = to_options(args.join(' '))
    Character.new(identifier: options['name'])
  end

  class << self

    # Splits a splits a string into a hash, e.g. "name: God Machine, purpose: World destruction" becomes
    # { name: 'God Machine', purpose: 'World Destruction' }. Keys are automatically downcased.
    def to_options(args)
      array = args.split(COMMANDS_CONFIG['options']['separator'])
      array.map!(&:lstrip)

      options = {}
      array.each do |pair|
        key_value = pair.split(COMMANDS_CONFIG['options']['inner_separator'])
        options[key_value[0].downcase] = key_value[1].lstrip
      end

      options
    end
  end
end
