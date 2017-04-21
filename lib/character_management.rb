# Handles character-related commands, such as create, update, and inspect.
module CharacterManagement
  extend Discordrb::Commands::CommandContainer

  require 'erb'
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

    options = Utilities::to_options(args.join(' '))

    ActiveRecord::Base.establish_connection(DB_CONFIG)

    begin
      character = Character.new(options)
    rescue ActiveModel::UnknownAttributeError => errors
    end

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
end
