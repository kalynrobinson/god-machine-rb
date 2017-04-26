# Stores roll types.
module Rolls
  NDS = 0
  ORPHAN = 1
  MINMAX = 2
  ATTRIBUTES = 3
  ALIAS = 4
  EMPTY = 6

  SUCCESSES = [8, 9, 10]

  ROLLABLE = %w{intelligence wits resolve strength dexterity stamina presence manipulation composure
              academics computer crafts investigation medicine occult politics science athletics brawl
              drive firearms larceny stealth survival weaponry animal_ken empathy expression intimidation
              persuasion socialize streetwise subterfuge health current_health willpower current_willpower
              power resource current_resource integrity size speed defense armor initiative }
end
