# Each level describes enemy positions for that level.
# TODO give this better structure.
const levels = [
  # [Vector2(700, 200)],
  {'Soldier': [
    Vector2(700, 200), Vector2(700, 300), Vector2(700, 100),
    Vector2(850, 200), Vector2(850, 300), Vector2(850, 100)],
  },
  {'Soldier': [
    Vector2(700, 200), Vector2(700, 300), Vector2(700, 100),
    Vector2(850, 200), Vector2(850, 300), Vector2(850, 100),
    Vector2(1000, 200), Vector2(1000, 300), Vector2(1000, 100)],
  },
]

# TODO introduce some randomness here.
func get_level(i):
  if i >= levels.size():
    return null
  return levels[i]
