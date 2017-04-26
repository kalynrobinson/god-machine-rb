# Handles commands related to random number generation.
module RNG
  extend Discordrb::Commands::CommandContainer

  require 'yaml'
  require 'erb'
  require_relative 'constants/attributes'
  require_relative 'constants/patterns'
  require_relative 'constants/rolls'
  require_relative 'models/character'

  COMMANDS_CONFIG = YAML.load_file('./config/commands.yaml')
  ENV = YAML.load(ERB.new(File.read('config/environment.yml')).result)['environment']
  DB_CONFIG = YAML.load(ERB.new(File.read('config/database.yml')).result)[ENV]

  # Generates a random number between 0 and 1, 0 and max or min and max.
  command(:random, min_args: 0, max_args: 2,
          description: COMMANDS_CONFIG['random']['description'],
          usage: COMMANDS_CONFIG['random']['description'],
          parameters: COMMANDS_CONFIG['random']['parameters']) do |event, min, max|
    roll, min, max = random_command(min, max)

    result = calculate_result(min, max, roll)

    event.channel.send_embed do |embed|
      embed.title = COMMANDS_CONFIG['random']['results'][result]['message']
      embed.colour = COMMANDS_CONFIG['random']['color']
      embed.description = roll

      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new url: COMMANDS_CONFIG['random']['results'][result]['thumbnail']
      embed.author = Discordrb::Webhooks::EmbedAuthor.new name: "Generating random number from #{min} to #{max}...",
                                                          icon_url: COMMANDS_CONFIG['random']['icon']
    end
  end

  # Simulates a dice roll in a variety of ways, depending on the given inputs, e.g.
  # NdS+/-F (usage 1d10, d10, 3d6+3, 2d20-5) rolls N dice with S sides and adds or subtracts given offset F.
  # min-max+/-F (usage 1-10, 1-3+5, 1-20-3) rolls one dice between min and max, then adds or subtracts given offset F.
  # S+/-F (usage 10, 5+3, 4-1) rolls one dice between 1 and S, inclusive, and adds or subtracts given offset F.
  # Empty (no dice arguments given) rolls one dice between 1 and 10 with no offset.
  #
  # Supports the following flags:
  # --successes: explodes critical successes as defined in the settings. Defaults to exploding 10s.
  # --sum: outputs sum of all dice rolls.
  command(:roll, description: COMMANDS_CONFIG['roll']['description'],
          usage: COMMANDS_CONFIG['roll']['usage'],
          parameters: COMMANDS_CONFIG['roll']['parameters']) do |event, *args|
    dice, rolls, offset, flags, min, max = roll_command(args)

    unless rolls == -1
      do_sum = flags.include?('--sum') || flags.include?('--s')
      do_successes = flags.include?('--successes') || flags.include?('--sc')
      agains = get_agains(flags)

      sum = rolls.inject(:+) + offset.to_i
      result = calculate_result(min, max, sum)

      event.channel.send_embed do |embed|
        embed.title = COMMANDS_CONFIG['roll']['results'][result]['message']
        embed.colour = COMMANDS_CONFIG['roll']['color']
        embed.description = rolls.map { |r| agains.any? && agains.include?(r) ? "**#{r}**" : r }.join(' + ')
        embed.description += ' *%{operator} %{offset}* ' %
            { operator: offset[0], offset: offset[1..offset.length] } if offset
        embed.description += " = #{sum}" if do_sum
        embed.description += "\n\n**%{successes} successes**" %
            { successes: rolls.select { |r| Rolls::SUCCESSES.include? r }
                                                            .length } if do_successes

        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new url: COMMANDS_CONFIG['roll']['results'][result]['thumbnail']
        embed.author = Discordrb::Webhooks::EmbedAuthor.new name: 'Rolling %{dice}...' % { dice: dice.join(' ') },
                                                            icon_url: COMMANDS_CONFIG['roll']['icon']
      end
    else
      event.channel.send_embed do |embed|
        embed.title = COMMANDS_CONFIG['roll']['results']['failure']['message']
        embed.colour = COMMANDS_CONFIG['roll']['color']
        embed.description = COMMANDS_CONFIG['roll']['results']['failure']['description']

        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new url: COMMANDS_CONFIG['roll']['results']['failure']['thumbnail']
        embed.author = Discordrb::Webhooks::EmbedAuthor.new name: 'Failed to roll %{dice}...' % { dice: dice.join(' ') },
                                                            icon_url: COMMANDS_CONFIG['roll']['icon']
      end
    end
  end

  # Uses a character's attributes to roll Nd10, where N is the sum of the attributes.
  command(:rollfor, description: COMMANDS_CONFIG['rollfor']['description'],
          usage: COMMANDS_CONFIG['rollfor']['usage'],
          parameters: COMMANDS_CONFIG['rollfor']['parameters']) do |event, *args|
    character, errors, flags, attributes = setup_rollfor_command(args)

    unless errors.any?
      rolls, number = rollfor_command(character, attributes, flags)

      no_successes = flags.include?('--no-successes') || flags.include?('--ns')
      no_10_again = flags.include?('--no-10-again') || flags.include?('--no-10')

      agains = get_agains(flags)
      agains << 10 unless no_10_again

      successes = get_successes(rolls)
      result = calculate_result(0, number, successes)

      event.channel.send_embed do |embed|
        embed.title = COMMANDS_CONFIG['rollfor']['results'][result]['message']
        embed.colour = COMMANDS_CONFIG['rollfor']['color']
        embed.description = rolls.map { |r| agains.any? && agains.include?(r) ? "**#{r}**" : r }.join(' + ')
        embed.description += "\n\n**#{successes} successes**" unless no_successes

        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new url: COMMANDS_CONFIG['rollfor']['results'][result]['thumbnail']
        embed.author = Discordrb::Webhooks::EmbedAuthor.new name: "Rolling #{number}d10 for #{character['identifier']}...",
                                                            icon_url: COMMANDS_CONFIG['rollfor']['icon']
      end
    else
      event.channel.send_embed do |embed|
        embed.title = COMMANDS_CONFIG['rollfor']['results']['failure']['message']
        embed.colour = COMMANDS_CONFIG['rollfor']['color']
        embed.description = "Roll failed for the following reasons:\n • %{errors}" %
            { errors: errors.join("\n • ") }

        embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new url: COMMANDS_CONFIG['rollfor']['results']['failure']['thumbnail']
        embed.author = Discordrb::Webhooks::EmbedAuthor.new name: "Roll for #{args[0]} failed.",
                                                            icon_url: COMMANDS_CONFIG['rollfor']['icon']
      end
    end
  end

  class << self
    def get_agains(flags)
      flags.map { |f| $1.to_i if f =~ Patterns::NAGAIN }
           .select { |f| f }
    end

    def get_successes(rolls)
      rolls.select { |r| Rolls::SUCCESSES.include? r }.length
    end

    def setup_rollfor_command(args)
      identifier = args.shift
      flags, attributes = args.map(&:downcase)
                              .join(' ')
                              .gsub('animal ken', 'animal_ken')
                              .split(' ')
                              .partition { |p| p.start_with? '--' }

      ActiveRecord::Base.establish_connection(DB_CONFIG)
      character = Character.where(identifier: identifier).first.as_json
      ActiveRecord::Base.connection.close

      errors = []
      if character && attributes.any?
        specific_attributes = Utilities::specific_array(attributes)
        invalid_attr = specific_attributes - character.keys
        errors += invalid_attr.map.with_index { |_a, i| "unknown attribute '#{attributes[i]}' for Character." } if invalid_attr.length > 0

        invalid_attr = specific_attributes - Rolls::ROLLABLE
        errors += invalid_attr.map { |_a, i| "attribute '#{attributes[i]}' is not a number." } if invalid_attr.length > 0
      elsif character && attributes.none?
        errors += ['No attributes were specified.']
      elsif not character
        errors += ["#{identifier} does not exist."]
      end

      return character, errors, flags, attributes
    end

    def calculate_result(min, max, sum)
      median = ((max - min + 1).to_f / 2).ceil
      case sum
      when min
        return 'crit fail'
      when min+1..median-1
        return 'fail'
      when median
        return 'average'
      when median+1..max-1
        return 'success'
      when max..1000
        return 'crit success'
      else
        return 'average'
      end
    end

    def rollfor_command(character, attributes, flags)
      sides = 10
      specific_attributes = Utilities::specific_array(attributes)
      number = specific_attributes.inject(0) { |sum, attr| sum + character[attr].to_i }

      flags << '--10-again' unless flags.include?('--no-10-again') || flags.include?('--no-10')

      return roll_nds(number, sides, flags), number
    end

    def random_command(min, max)
      if min && max
        return rand(min.to_i..max.to_i), min.to_i, max.to_i
      elsif max
        return rand(1..max.to_i), 1, max.to_i
      else
        return rand(1..10), 1, 10
      end
    end

    def roll_command(args)
      # Downcase all arguments and then split into dice arguments and flag arguments.
      args.map!(&:downcase)
      flags, dice = args.partition { |p| p.start_with? '--' }

      # Roll dice.
      rolls, offset, min, max = roll(dice, flags)

      return dice, rolls, offset, flags, min, max
    end

    # Determines type of roll: NdS, min-max, orphan, empty, attributes, or alias.
    def roll(dice, flags)
      # If first argument is a flag, assume roll is empty type and replace with 1d10.
      dice[0] = ['1d10'] unless dice

      case dice[0]
      when Patterns::MINMAX
        min = $1.to_i + $3.to_i
        max = $2.to_i + $3.to_i
        return roll_minmax($1, $2, flags), $3, min, max
      when Patterns::ORPHAN
        min = 1
        max = dice[0]
        return roll_minmax(min, max, flags), nil, min, max
      when Patterns::NDS
        min = (1 * $1.to_i) + $3.to_i
        max = ($2.to_i * $1.to_i) + $3.to_i
        return roll_nds($1, $2, flags), $3, min, max
      else
        -1
      end
    end

    def roll_nds(number, sides, flags)
      # Split NdS into [N, S] and manually designate N=1 if no N is given
      number = 1 if number == ''

      rolls = []
      agains = get_agains(flags)

      # Roll dice N times and collect in rolls array.
      (1..number.to_i).each do
        rolls += rng(1, sides.to_i, agains)
      end

      rolls
    end

    def roll_minmax(min, max, flags)
      rng(min.to_i, max.to_i, get_agains(flags))
    end

    def rng(min, max, agains)
      rolls = []

      # Roll initial dice.
      current = rand(min..max)
      rolls << current

      # Explode critical successes if explode flag is given.
      # Guard against infinite loops by allowing only 50 explosions.
      while agains.include?(current) && rolls.length < COMMANDS_CONFIG['roll']['timeout']
        current = rand(min..max)
        rolls << current
      end

      rolls
    end
  end
end
