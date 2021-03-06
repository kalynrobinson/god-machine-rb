class Character < ActiveRecord::Base
  validates :identifier, presence: true,
                         uniqueness: { case_sensitive: true },
                         length: { maximum: 255 },
                         format: {
                           :with => /\A[^,\s]+\z/,
                           :message => 'Commas and spaces are not allowed in identifier.'
                         }

  validates :virtue, length: { maximum: 255 }
  validates :vice, length: { maximum: 255 }
  validates :concept, length: { maximum: 255 }
  validates :xsplat, length: { maximum: 255 }
  validates :ysplat, length: { maximum: 255 }
  validates :zsplat, length: { maximum: 255 }

  # Attributes
  validates :intelligence, numericality: { only_integer: true }, allow_nil: true
  validates :wits, numericality: { only_integer: true }, allow_nil: true
  validates :resolve, numericality: { only_integer: true }, allow_nil: true
  validates :strength, numericality: { only_integer: true }, allow_nil: true
  validates :dexterity, numericality: { only_integer: true }, allow_nil: true
  validates :stamina, numericality: { only_integer: true }, allow_nil: true
  validates :presence, numericality: { only_integer: true }, allow_nil: true
  validates :manipulation, numericality: { only_integer: true }, allow_nil: true
  validates :composure, numericality: { only_integer: true }, allow_nil: true

  # Abilities
  validates :academics, numericality: { only_integer: true }, allow_nil: true
  validates :computer, numericality: { only_integer: true }, allow_nil: true
  validates :crafts, numericality: { only_integer: true }, allow_nil: true
  validates :investigation, numericality: { only_integer: true }, allow_nil: true
  validates :medicine, numericality: { only_integer: true }, allow_nil: true
  validates :occult, numericality: { only_integer: true }, allow_nil: true
  validates :politics, numericality: { only_integer: true }, allow_nil: true
  validates :science, numericality: { only_integer: true }, allow_nil: true

  validates :athletics, numericality: { only_integer: true }, allow_nil: true
  validates :brawl, numericality: { only_integer: true }, allow_nil: true
  validates :drive, numericality: { only_integer: true }, allow_nil: true
  validates :firearms, numericality: { only_integer: true }, allow_nil: true
  validates :larceny, numericality: { only_integer: true }, allow_nil: true
  validates :stealth, numericality: { only_integer: true }, allow_nil: true
  validates :survival, numericality: { only_integer: true }, allow_nil: true
  validates :weaponry, numericality: { only_integer: true }, allow_nil: true

  validates :animal_ken, numericality: { only_integer: true }, allow_nil: true
  validates :empathy, numericality: { only_integer: true }, allow_nil: true
  validates :expression, numericality: { only_integer: true }, allow_nil: true
  validates :intimidation, numericality: { only_integer: true }, allow_nil: true
  validates :persuasion, numericality: { only_integer: true }, allow_nil: true
  validates :socialize, numericality: { only_integer: true }, allow_nil: true
  validates :streetwise, numericality: { only_integer: true }, allow_nil: true
  validates :subterfuge, numericality: { only_integer: true }, allow_nil: true

  # Resources
  validates :health, numericality: { only_integer: true }, allow_nil: true
  validates :current_health, numericality: { only_integer: true }, allow_nil: true
  validates :willpower, numericality: { only_integer: true }, allow_nil: true
  validates :current_willpower, numericality: { only_integer: true }, allow_nil: true
  validates :power, numericality: { only_integer: true }, allow_nil: true
  validates :resource, numericality: { only_integer: true }, allow_nil: true
  validates :current_resource, numericality: { only_integer: true }, allow_nil: true
  validates :morality, numericality: { only_integer: true }, allow_nil: true

  # Combat modifiers
  validates :size, numericality: { only_integer: true }, allow_nil: true
  validates :speed, numericality: { only_integer: true }, allow_nil: true
  validates :defense, numericality: { only_integer: true }, allow_nil: true
  validates :armor, numericality: { only_integer: true }, allow_nil: true
  validates :initiative, numericality: { only_integer: true }, allow_nil: true

  # Experience
  validates :beats, numericality: { only_integer: true }, allow_nil: true
  validates :experience, numericality: { only_integer: true }, allow_nil: true
end