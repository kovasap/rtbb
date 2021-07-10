extends TileMap

# TODO find a better way to do this than hardcoding 7 here. This exists because
# the tiles seem to start at the origin of the Game node, the parent of this
# node, which happens to be 7 tiles to the left of this node.
const min_tile = Vector2(7, 0)
const max_tile = min_tile + Vector2(26, 20)
const midpoint_tile = min_tile.x + 12


# Transforms a screen coordinate position to a screen coordinate position of
# the closest map tile.
func world_to_tile_coordinates(position, left_of_midpoint=false):
  var max_modifier = Vector2(- max_tile.x + midpoint_tile, 0) if left_of_midpoint \
      else Vector2(0,0)
  return map_to_world(clamp_to_bounds(world_to_map(position), max_modifier))

func clamp_to_bounds(tile, max_modifier=Vector2(0,0), min_modifier=Vector2(0,0)):
  var clamped_tile = Vector2(0, 0)
  var max_bound = max_tile + max_modifier
  var min_bound = min_tile + min_modifier
  if tile.x > max_bound.x:
    clamped_tile.x = max_bound.x
  elif tile.x < min_bound.x:
    clamped_tile.x = min_bound.x
  else:
    clamped_tile.x = tile.x
  if tile.y > max_bound.y:
    clamped_tile.y = max_bound.y
  elif tile.y < min_bound.y:
    clamped_tile.y = min_bound.y
  else:
    clamped_tile.y = tile.y
  return clamped_tile

