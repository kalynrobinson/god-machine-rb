# This simple bot responds to every "Ping!" message with a "Pong!"

require 'active_record'
require 'discordrb'
require 'yaml'
require_relative 'rng'
require_relative 'character_management'

CONFIG = YAML.load(ERB.new(File.read('./config/token.yaml')).result)

bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'],
                                          client_id: CONFIG['client_id'],
                                          prefix: CONFIG['prefix']
cogs = [RNG, CharacterManagement, Utilities]
cogs.each { |cog| bot.include! cog }

unless File.exist? CONFIG['invite']
  invite = open(CONFIG['invite'], 'w')
  invite.write(bot.invite_url)
end

bot.run
