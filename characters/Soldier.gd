extends Character

class_name Soldier

# https://github.com/godotengine/godot/issues/21789
func get_class(): return 'Soldier'

func _ready():
  cost = 2
  max_health = 5
  attack_range = 10
  attack_cooldown = 100
  attack_damage = 2
  faction_sprites = {
    'enemy': preload('res://sprites/chess/black_pawn.png'),
    'friendly': preload('res://sprites/chess/white_pawn.png'),
  }
  ._ready()

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

func _on_SlashAnimation_animation_finished():
  $MeleeHitbox/SlashAnimation.stop()
  $MeleeHitbox/SlashAnimation.frame = 4
  if cur_target != null:
    cur_target.update_health(-attack_damage)

