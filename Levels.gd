# Logic to generate game levels.  Can be accessed accross the project with the
# "Levels" Autoloaded scene.

extends Node2D

const char_mapping = {
  's': 'Soldier',
  't': 'Thrower',
  'm': 'Mystic',
  'h': 'Healer',
  'a': 'Assassin',
}


# Each level describes enemy positions for that level.
# TODO introduce some randomness here.
const levels = {
  0: """
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ s _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ s _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ s _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ s _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
"""

}


# Returns true if there is a next level to load (and loads it), false otherwise.
func load_level(i):
  Game.move_all_characters('enemy', null)
  for c in Game.characters['party']:
    c.reset()
  if not levels.has(i):
    return false
  var battlefield = Game.get_node('Battlefield')
  var rows = levels[i].split('\n')
  for y in rows.size():
    var cols = rows[y].split(' ')
    for x in cols.size():
      var tile = cols[x]
      if tile == '_' or tile == '':
        continue
      elif char_mapping.has(tile):
        var pos = battlefield.map_to_world(battlefield.min_tile + Vector2(x, y))
        var enemy = Game.make_character(pos, 'enemy', char_mapping[tile])
        Game.characters['enemy'].append(enemy)
      else:
        assert(false, 'Unrecognized tile %s' % tile)
  return true
