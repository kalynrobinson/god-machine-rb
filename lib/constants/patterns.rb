# Stores regex pattern constants.
module Patterns
  # NdS rolls, e.g. d10, 1d3, 3D5+3, 2d20-4
  NDS = /^(\d*)[dD](\d+)([+-]\d+)?$/
  # Orphan rolls, e.g. 1, 10, 3.
  ORPHAN = /^\d+$/
  # min-max rolls, e.g. 1-10, 5-20+3, 4-10-4
  MINMAX = /^(\d+)-(\d+)([+-]\d+)?$/
end
