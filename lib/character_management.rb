# Handles character-related commands, such as create, update, and inspect.
module CharacterManagement
  extend Discordrb::Commands::CommandContainer
  extend Discordrb::EventContainer

  require 'erb'
  require 'pp'
  require_relative 'models/character'
  require_relative 'utilities'

  COMMANDS_CONFIG = YAML.load_file('./config/commands.yaml')
  ENV = YAML.load(ERB.new(File.read('config/environment.yml')).result)['environment']
  DB_CONFIG = YAML.load(ERB.new(File.read('config/database.yml')).result)[ENV]

  # Generates a random number between 0 and 1, 0 and max or min and max.
  command(:create, min_args: 1,
          description: COMMANDS_CONFIG['create']['description'],
          usage: COMMANDS_CONFIG['create']['usage'],
          parameters: COMMANDS_CONFIG['create']['parameters']) do |event, *args|

    ActiveRecord::Base.establish_connection(DB_CONFIG)
    options, character, errors = create_character(args)

    if character && character.save
      # Note: Close before sending embed to avoid accidentally outputting a message
      ActiveRecord::Base.connection.close
      event.channel.send_embed do |embed|
        embed.title = COMMANDS_CONFIG['create']['results']['success']['message']
        embed.colour = COMMANDS_CONFIG['create']['color']
        embed.description = "#{character.identifier} was created with the following attributes:"
        options.each { |key, value| embed.description += "\n• **#{key}:** #{value}" }

        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new url: COMMANDS_CONFIG['create']['results']['success']['thumbnail']
        embed.author = Discordrb::Webhooks::EmbedAuthor.new name: "#{character.identifier} created!",
                                                            icon_url: COMMANDS_CONFIG['create']['icon']
      end
    else
      # Note: Close before sending embed to avoid accidentally outputting a message
      ActiveRecord::Base.connection.close
      errors = character.errors.full_messages.join("\n • ") unless errors
      event.channel.send_embed do |embed|
        embed.title = COMMANDS_CONFIG['create']['results']['failure']['message']
        embed.colour = COMMANDS_CONFIG['create']['color']
        embed.description = "#{options[:identifier]} could not be created for the following reasons:\n • #{errors}"

        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new url: COMMANDS_CONFIG['create']['results']['failure']['thumbnail']
        embed.author = Discordrb::Webhooks::EmbedAuthor.new name: "#{options[:identifier]} could not be created.",
                                                            icon_url: COMMANDS_CONFIG['create']['icon']
      end
    end
  end

  command(:set, min_args: 1,
          description: COMMANDS_CONFIG['set']['description'],
          usage: COMMANDS_CONFIG['set']['usage'],
          parameters: COMMANDS_CONFIG['set']['parameters']) do |event, *args|

    ActiveRecord::Base.establish_connection(DB_CONFIG)
    options, saved, errors = update_character(args)
    ActiveRecord::Base.connection.close

    if saved
      event.channel.send_embed do |embed|
        embed.title = COMMANDS_CONFIG['set']['results']['success']['message']
        embed.colour = COMMANDS_CONFIG['set']['color']
        embed.description = "#{options[:identifier]} was successfully updated with the following attributes:"
        options.each { |key, value| embed.description += "\n• **#{key}:** #{value}" }

        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new url: COMMANDS_CONFIG['set']['results']['success']['thumbnail']
        embed.author = Discordrb::Webhooks::EmbedAuthor.new name: "#{options[:identifier]} updated!",
                                                            icon_url: COMMANDS_CONFIG['set']['icon']
      end
    else
      event.channel.send_embed do |embed|
        embed.title = COMMANDS_CONFIG['set']['results']['failure']['message']
        embed.colour = COMMANDS_CONFIG['set']['color']
        embed.description = "#{options[:identifier]} could not be updated for the following reasons:\n • %{errors}" %
            { errors: errors }

        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new url: COMMANDS_CONFIG['set']['results']['failure']['thumbnail']
        embed.author = Discordrb::Webhooks::EmbedAuthor.new name: "#{options[:identifier]} could not be updated.",
                                                            icon_url: COMMANDS_CONFIG['set']['icon']
      end
    end
  end

  command(:sheet, min_args: 1, max_args: 1,
          description: COMMANDS_CONFIG['sheet']['description'],
          usage: COMMANDS_CONFIG['sheet']['usage'],
          parameters: COMMANDS_CONFIG['sheet']['parameters']) do |event, identifier|

    ActiveRecord::Base.establish_connection(DB_CONFIG)
    character = Character.where(identifier: identifier).first
    ActiveRecord::Base.connection.close

    if character
      json = character.as_json
      basics = Attributes::BASICS.map { |attr| "**#{attr.capitalize}** #{json[attr]}" }

      attributes = []
      Attributes::ATTRIBUTES.each do |attribute|
        attributes << "===#{attribute[:name]}==="
        attributes += attribute[:attributes].map { |attr| '**%{attribute}** %{dots}' %
            { attribute: attr.capitalize, dots: 'o' * json[attr].to_i } }
        attributes << ''
      end

      skills = []
      max_length = Attributes::SKILLS.map { |s| s[:skills] }.flatten.max_by(&:length).length
      full_width = max_length + 8
      Attributes::SKILLS.each do |skill|
        skills << '```Markdown'
        skills << '%{padding}%{name}' % { padding: ' ' * ((full_width-skill[:name].length) / 2),
                                          name: skill[:name].capitalize }
        skills << '=' * full_width
        unskilled = "(#{skill[:unskilled]} unskilled)"
        skills << '%{padding}%{unskilled}' % { padding: ' ' * ((full_width-unskilled.length) / 2),
                                               unskilled: unskilled }
        skills += skill[:skills].map { |attr| '<%{attribute}>%{padding} %{dots}' %
            { padding: ' ' * (max_length - attr.length),
              attribute: attr.capitalize,
              dots: 'o' * json[attr].to_i  + '-' * (5-json[attr].to_i) } }
        skills << '```'
      end

      entries = [
          basics.join("\n"),
          attributes.join("\n"),
          skills.join("\n"),
          "**Virtue** #{character.virtue}",
          "**Vice** #{character.vice}",
      ]

      p = Pages::Pages.new event.bot, event.message, entries, per_page=1,
                           emojis=COMMANDS_CONFIG['sheet']['emojis'], numbered=false,
                           embed= { author: { name: character.name,
                                                    icon_url: COMMANDS_CONFIG['sheet']['icon'] } }
      p.paginate
    else
      event.channel.send_embed do |embed|
        embed.colour = COMMANDS_CONFIG['sheet']['color']
        embed.description = COMMANDS_CONFIG['sheet']['results']['failure']['description']

        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new url: COMMANDS_CONFIG['sheet']['results']['failure']['thumbnail']
        embed.author = Discordrb::Webhooks::EmbedAuthor.new name: "#{identifier} does not exist.",
                                                            icon_url: COMMANDS_CONFIG['sheet']['icon']
      end
    end

    ''
  end

  class << self
    def update_character(args)
      identifier, options = parse_args(args)
      character = Character.where(identifier: identifier).first
      generic_options = Utilities::specific_options(options)

      begin
        saved = character ? character.update_attributes(generic_options) : false
        errors = character ? character.errors.full_messages.join("\n • ") : "#{identifier} does not exist."
      rescue ActiveModel::UnknownAttributeError => errors
      end

      return options, saved, errors
    end

    def create_character(args)
      identifier, options = parse_args(args)
      options[:identifier] = identifier
      generic_options = Utilities::specific_options(options)

      begin
        character = Character.new(generic_options)
      rescue ActiveModel::UnknownAttributeError => errors
      end

      return options, character, errors
    end

    def parse_args(args)
      identifier = args.shift
      options = Utilities::to_options(args.join(' '))

      return identifier, options
    end
  end
end
