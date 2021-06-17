extends Character

class_name Thrower

func _ready():
  cost = 3
  max_health = 4
  projectile_speed = 1000
  attack_range = 3000
  attack_cooldown = 50
  attack_damage = 3
  ._ready()

# Find the closest character to me and go one speed step towards it.  Attack if
# possible.
func act(game):
  if dead or dragging:
    return
  var closest_char = get_closest_char(game.battlefield_characters)
  if closest_char == null:
    cur_velocity = Vector2(0, 0)
    return
  var direction = self.position.direction_to(closest_char.position)
  self.rotation = direction.angle()
  var distance = self.position.distance_to(closest_char.position)
  if distance > adjacency_distance and distance > attack_range:
    cur_velocity = speed * direction
  else:
    cur_velocity = Vector2(0, 0)
  if distance < attack_range:
    if time_until_next_attack == 0:
      shoot(direction)
      time_until_next_attack = attack_cooldown
  time_until_next_attack -= 1
