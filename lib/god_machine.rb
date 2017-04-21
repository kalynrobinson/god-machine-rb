# This simple bot responds to every "Ping!" message with a "Pong!"

require 'discordrb'
require 'yaml'
require_relative 'rng'
require_relative 'character_management'

CONFIG = YAML.load_file('./config/token.yaml')
bot = Discordrb::Commands::CommandBot.new token: CONFIG['token'],
                                          client_id: CONFIG['client_id'],
                                          prefix: CONFIG['prefix']
bot.include! RNG
bot.include! CharacterManagement

unless File.exist? CONFIG['invite']
  invite = open(CONFIG['invite'], 'w')
  invite.write(bot.invite_url)
end

bot.run
