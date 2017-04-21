class CharactersMigration < ActiveRecord::Migration[5.0]
  def change
    create_table :characters do |t|
      # Basics
      t.string :identifier
      t.string :name
      t.integer :age
      t.string :virtue
      t.string :vice
      t.string :concept
      t.string :faction
      t.string :group_name

      # Attributes
      t.integer :intelligence
      t.integer :wits
      t.integer :resolve
      t.integer :strength
      t.integer :dexterity
      t.integer :stamina
      t.integer :presence
      t.integer :manipulation
      t.integer :composure

      # Abilities
      t.integer :academics
      t.integer :computer
      t.integer :crafts
      t.integer :investigation
      t.integer :medicine
      t.integer :occult
      t.integer :politics
      t.integer :science

      t.integer :athletics
      t.integer :brawl
      t.integer :drive
      t.integer :firearms
      t.integer :larceny
      t.integer :stealth
      t.integer :survival
      t.integer :weaponry

      t.integer :animal_ken
      t.integer :empathy
      t.integer :expression
      t.integer :intimidation
      t.integer :persuasion
      t.integer :socialize
      t.integer :streetwise
      t.integer :subterfuge

      # Resources
      t.integer :health
      t.integer :willpower
      t.integer :current_health
      t.integer :current_willpower
      t.integer :integrity

      # Combat
      t.integer :size
      t.integer :speed
      t.integer :defense
      t.integer :armor
      t.integer :initiative
      t.integer :beats
      t.integer :experience

      # Relationships
      t.integer :chronicle_id
      t.integer :player_id
      t.timestamps
    end
  end
end
