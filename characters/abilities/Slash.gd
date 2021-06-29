extends Ability

class_name Slash

var cur_target

var damage = 3

func use(using_character, battlefield_characters):
  var target = using_character.get_closest_char(battlefield_characters)
  if target.get_node('Hitbox').overlaps_area($MeleeHitbox):
    $MeleeHitbox/SlashAnimation.frame = 0
    $MeleeHitbox/SlashAnimation.play()
    cur_target = target
    return true
  return false

func on_every_try(using_character, battlefield_characters):
  var target = using_character.get_closest_char(battlefield_characters)
  var direction = using_character.position.direction_to(target.position)
  $MeleeHitbox.rotation = direction.angle() - using_character.rotation

# If the animation is triggered again before the first animation is finished,
# this signal will not be emitted, and this function will not be called!
func _on_SlashAnimation_animation_finished():
  $MeleeHitbox/SlashAnimation.stop()
  $MeleeHitbox/SlashAnimation.frame = 4
  if cur_target != null:
    cur_target.update_health(-damage)
