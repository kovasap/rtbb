extends Character

class_name Assassin

# https://github.com/godotengine/godot/issues/21789
func get_class(): return 'Assassin'

var teleport_cooldown = 200
var time_until_next_teleport = 0

func _ready():
  cost = 2
  max_health = 2
  attack_range = 10
  attack_cooldown = 40
  attack_damage = 4
  faction_sprites = {
    'enemy': preload('res://sprites/chess/black_queen.png'),
    'friendly': preload('res://sprites/chess/white_queen.png'),
  }
  ._ready()


# Teleport to the furthest character.  Attack if possible.
func act():
  if dead or dragging:
    return
  var closest_char = get_closest_char(get_parent().get_battlefield_characters())
  var furthest_char = get_furthest_char(get_parent().get_battlefield_characters())
  if closest_char == null:
    self.linear_velocity = Vector2(0, 0)
    return

  var direction = self.position.direction_to(closest_char.position)
  $MeleeHitbox.rotation = direction.angle() - self.rotation
  var distance = self.position.distance_to(closest_char.position)

  # Teleport
  if time_until_next_teleport < 0:
    self.position = furthest_char.position + 50 * direction
    time_until_next_teleport = teleport_cooldown
  time_until_next_teleport -= 1

  if distance > adjacency_distance and distance > attack_range:
    self.linear_velocity = speed_modifier * speed * direction
  else:
    self.linear_velocity = Vector2(0, 0)
  if time_until_next_attack <= 0 and try_attack(closest_char):
      time_until_next_attack = attack_cooldown
  time_until_next_attack -= 1

# Returns if the attack happened or not
func try_attack(target_character):
  if target_character.get_node('Hitbox').overlaps_area($MeleeHitbox):
    slash(target_character)
    return true
  return false

func slash(target_character):
  $MeleeHitbox/SlashAnimation.frame = 0
  $MeleeHitbox/SlashAnimation.play()
  cur_target = target_character

# If the animation is triggered again before the first animation is finished,
# this signal will not be emitted, and this function will not be called!
func _on_SlashAnimation_animation_finished():
  $MeleeHitbox/SlashAnimation.stop()
  $MeleeHitbox/SlashAnimation.frame = 4
  if cur_target != null:
    cur_target.update_health(-attack_damage)

