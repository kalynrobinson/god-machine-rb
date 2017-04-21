# Handles commands related to random number generation.
module RNG
  extend Discordrb::Commands::CommandContainer

  require 'yaml'
  require_relative 'constants/attributes'
  require_relative 'constants/patterns'
  require_relative 'constants/rolls'

  COMMANDS_CONFIG = YAML.load_file('./config/commands.yaml')

  # Generates a random number between 0 and 1, 0 and max or min and max.
  command(:random, min_args: 0, max_args: 2,
          description: COMMANDS_CONFIG['random']['description'],
          usage: COMMANDS_CONFIG['random']['description'],
          parameters: COMMANDS_CONFIG['random']['parameters']) do |_event, min, max|
    random_command(min, max)
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
          parameters: COMMANDS_CONFIG['roll']['parameters']) do |_event, *args|
    roll_command(args)
  end

  command(:rollfor, description: COMMANDS_CONFIG['rollfor']['description'],
          usage: COMMANDS_CONFIG['rollfor']['usage'],
          parameters: COMMANDS_CONFIG['rollfor']['parameters']) do |_event, *args|

    # Downcase all arguments and then split into dice arguments and flag arguments.
    args.map!(&:downcase)
    flags, dice = args.partition { |p| p.start_with? '--' }
  end

  class << self
    def random_command(min, max)
      if max
        rand(min.to_i..max.to_i) if max
      elsif min
        rand(0..min.to_i) if min
      else
        rand
      end
    end

    def roll_command(args)
      # Downcase all arguments and then split into dice arguments and flag arguments.
      args.map!(&:downcase)
      flags, dice = args.partition { |p| p.start_with? '--' }

      # Roll dice.
      rolls, offset = roll(dice, flags)

      # Collect flags.
      sum = flags.include?('--sum') || flags.include?('--s')
      explode = flags.include?('--explode') || flags.include?('--e')
      to_explode = [10] # TODO: replace with setting

      # Output roll.
      output = "**Rolling %{dice}**:\n" % { dice: dice.join(' ') }
      output += rolls.map { |r| to_explode.include?(r) && explode ? "**#{r}**" : r }.join(' + ')
      output += ' *%{operator} %{offset}* ' % { operator: offset[0], offset: offset[1..offset.length] } if offset
      output += ' = %{sum}' % { sum: rolls.inject(:+) + offset.to_i } if sum

      output
    end

    # Determines type of roll: NdS, min-max, orphan, empty, attributes, or alias.
    def roll(dice, flags)
      # If first argument is a flag, assume roll is empty type and replace with 1d10.
      dice[0] = ['1d10'] unless dice

      case dice[0]
      when Patterns::MINMAX
        return roll_minmax($1, $2, flags), $3
      when Patterns::ORPHAN
        return roll_minmax(1, dice[0], flags), nil
      when Patterns::NDS
        return roll_nds($1, $2, flags), $3
      else
        -1
      end
    end

    def roll_nds(number, sides, flags)
      # Split NdS into [N, S] and manually designate N=1 if no N is given
      number = 1 if number.empty?

      rolls = []

      # Roll dice N times and collect in rolls array.
      (1..number.to_i).each do
        rolls += rng(1, sides.to_i, flags)
      end

      rolls
    end

    def roll_minmax(min, max, flags)
      rng(min.to_i, max.to_i, flags)
    end

    def rng(min, max, flags)
      # Collect explode flag used to reroll critical successes.
      explode = flags.include?('--explode') || flags.include?('--e')
      to_explode = [10] # TODO: replace with setting

      rolls = []

      # Roll initial dice.
      current = rand(min..max)
      rolls << current

      # Explode critical successes if explode flag is given.
      # Guard against infinite loops by allowing only 50 explosions.
      while explode && to_explode.include?(current) && rolls.length < COMMANDS_CONFIG['roll']['timeout']
        current = rand(min..max)
        rolls << current
      end

      rolls
    end
  end
end
