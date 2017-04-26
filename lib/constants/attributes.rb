# Stores constants related to character attributes.
module Attributes
  BASICS = %w{name player virtue vice concept}

  SKILLS = [
      { name: 'Mental',
        unskilled: -3,
        skills: %w{academics computer crafts investigation medicine occult politics science} },
      { name: 'Physical',
        unskilled: -1,
        skills: %w{athletics brawl drive firearms larceny stealth survival weaponry} },
      { name: 'Social',
        unskilled: -1,
        skills: %w{animal_ken empathy expression intimidation persuasion socialize streetwise subterfuge} },
  ]

  ATTRIBUTES = [
      { name: 'Mental',
        attributes: %w{intelligence wits resolve} },
      { name: 'Physical',
        attributes: %w{strength dexterity stamina} },
      { name: 'Social',
        attributes: %w{presence manipulation composure} },
  ]

  SPLATS = {
      xsplat: [:clan, :auspice, :path, :lineage, :seeming, :compact, :threshold, :decree, :agenda, :family],
      ysplat: [:covenant, :tribe, :order, :refinement, :court, :conspiracy, :archetype, :guild, :incarnation, :hunger],
      zsplat: [:bloodline, :lodge, :legacy, :kith, :faction, :key],
      power: [:blood_potency]
  }
end