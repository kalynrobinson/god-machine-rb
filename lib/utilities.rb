module Utilities
  extend Discordrb::Commands::CommandContainer

  require './lib/pages/pages'

  COMMANDS_CONFIG = YAML.load_file('./config/commands.yaml')

  command(:botpermissions, min_args: 0,
          description: COMMANDS_CONFIG['botpermissions']['description'],
          usage: COMMANDS_CONFIG['botpermissions']['usage']) do |event, *args|
    bot_profile = event.bot.profile.on(event.server)
    bot_profile.permissions
  end

  command(:react) do |event, *args|
    puts args.join(' ')
    event.message.react(args.join(' '))
    return
  end

  command(:page) do |event, *args|
    p = Pages::Pages.new event.bot, event.message, [1,2,3,4,5], per_page: 2
    p.paginate
  end

  class << self
    # Splits a splits a string into a hash, e.g. "name: God Machine, purpose: World destruction" becomes
    # { name: 'God Machine', purpose: 'World Destruction' }. Keys are automatically converted to symbols.
    def to_options(args)
      array = args.split(COMMANDS_CONFIG['options']['separator'])

      return {} unless array.any?

      array.map!(&:lstrip)

      options = {}
      array.each do |pair|
        key_value = pair.split(COMMANDS_CONFIG['options']['key_separator'])
        options[key_value[0].parameterize.underscore.to_sym] = key_value[1].lstrip
      end

      options
    end
  end
end