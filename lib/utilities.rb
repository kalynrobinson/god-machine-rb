module Utilities
  COMMANDS_CONFIG = YAML.load_file('./config/commands.yaml')

  class << self
    # Splits a splits a string into a hash, e.g. "name: God Machine, purpose: World destruction" becomes
    # { name: 'God Machine', purpose: 'World Destruction' }. Keys are automatically converted to symbols.
    def to_options(args)
      array = args.split(COMMANDS_CONFIG['options']['separator'])
      array.map!(&:lstrip)

      options = {}
      array.each do |pair|
        key_value = pair.split(COMMANDS_CONFIG['options']['key_separator'])
        options[key_value[0].parameterize.underscore.to_sym] = key_value[1].lstrip
      end

      options
    end
  end
end