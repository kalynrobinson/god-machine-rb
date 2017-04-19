# This simple bot responds to every "Ping!" message with a "Pong!"

require 'discordrb'
require 'yaml'

CONFIG = YAML.load_file('../config/token.yaml')
bot = Discordrb::Bot.new token: CONFIG['token'], client_id: CONFIG['client_id']

unless File.exist? CONFIG['invite']
  invite = open(CONFIG['invite'], 'w')
  invite.write(bot.invite_url)
end

bot.run