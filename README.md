# God Machine
A Discord bot that helps manage your Chronicles of Darkness/New World of Darkness tabletop games. 

[Join the test server to see God Machine in action!](https://discord.gg/H8bpaA8)

# Features
* Roll dice in a variety of formats with the `/roll` command. 
  * Currently supports *N*d*S*+/-*F* (e.g. 1d20+5) and
    *low*-*high*+/-*F* (e.g. 1-10+4) formats.
  * Current supports the flags `--sum` (to output sum of all rolls), 
  `--successes` (to output number successful rolls), and `--N-again` (to roll an additional die for each die that lands on
   *N*).
* Create and update characters with the `/create` and `/set` commands, with friendly error messages when attempting to
  use invalid attributes or edit a character that does not exist.
* View character profiles with `/sheet`. Character profiles are paginated using emoji reactions—click on `B` for basics, 
  `A` for attributes, `S` for skills, `M` for merits and flaws, and `E` for equipment!
* Roll for a specific character using *N*d10 dice, where *N* is the sum of the attributes you want to rollfor, using the 
  `/rollfor` command.

# Technical
* Comprehensive test suites.
* Uses Rails' ActiveRecord library for model validations, queries, and migrations—without Rails!
* Includes the Pages class, which can be used to paginate lists of things.

# Local Development
* Clone the god-machine repository.
* Run `bundle install` to install all gem dependencies.
* Rename `config/example.token.yaml` to `config/token.yaml` and replace the token and client_id with the relevant 
  information for your bot.
* Add environmental variables for `DB_USERNAME`, `DB_PASSWORD`, and `RUBY_ENV`. `RUBY_ENV` will default to 'production' if unset.
* Run `rake db:setup` to create, migrate, and seed the databases.
* `cd` to the god-machine folder and run `ruby lib/god_machine.rb`.

# Testing
* Run all unit tests using `rake test`.
* Run individual tests with `ruby tests/X_test.rb`.
* Certain unit tests (notably `tests/models/character_test.rb`) require the test database to be cleared before rerunning.
  Run `rake db:drop db:setup` to do so.