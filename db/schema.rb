# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170420005355) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "characters", force: :cascade do |t|
    t.string   "identifier"
    t.string   "name"
    t.string   "template"
    t.integer  "age"
    t.string   "virtue"
    t.string   "vice"
    t.string   "concept"
    t.string   "xsplat"
    t.string   "ysplat"
    t.string   "zsplat"
    t.integer  "intelligence"
    t.integer  "wits"
    t.integer  "resolve"
    t.integer  "strength"
    t.integer  "dexterity"
    t.integer  "stamina"
    t.integer  "presence"
    t.integer  "manipulation"
    t.integer  "composure"
    t.integer  "academics"
    t.integer  "computer"
    t.integer  "crafts"
    t.integer  "investigation"
    t.integer  "medicine"
    t.integer  "occult"
    t.integer  "politics"
    t.integer  "science"
    t.integer  "athletics"
    t.integer  "brawl"
    t.integer  "drive"
    t.integer  "firearms"
    t.integer  "larceny"
    t.integer  "stealth"
    t.integer  "survival"
    t.integer  "weaponry"
    t.integer  "animal_ken"
    t.integer  "empathy"
    t.integer  "expression"
    t.integer  "intimidation"
    t.integer  "persuasion"
    t.integer  "socialize"
    t.integer  "streetwise"
    t.integer  "subterfuge"
    t.integer  "health"
    t.integer  "willpower"
    t.integer  "morality"
    t.integer  "power"
    t.integer  "resource"
    t.integer  "current_health"
    t.integer  "current_willpower"
    t.integer  "current_resource"
    t.integer  "size"
    t.integer  "speed"
    t.integer  "defense"
    t.integer  "armor"
    t.integer  "initiative"
    t.integer  "beats"
    t.integer  "experience"
    t.integer  "chronicle_id"
    t.integer  "player_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

end
