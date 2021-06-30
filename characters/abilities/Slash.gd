extends Ability

class_name Slash

var cur_target

var damage = 3

func use(using_character, battlefield_characters):
  var target = using_character.get_closest_char(battlefield_characters)
  if target.get_node('Hitbox').overlaps_area($MeleeHitbox):
    if cooldown < 50:
      # If the animation is triggered again before the first animation is
      # finished, the amimation_finished signal will not be emitted, and
      # therefore damage will not be applied.  This aims to fix this by making
      # the animation finish faster where there is a low cooldown.
      $MeleeHitbox/SlashAnimation.speed_scale = 50 / cooldown
    $MeleeHitbox/SlashAnimation.frame = 0
    $MeleeHitbox/SlashAnimation.play()
    cur_target = target
    return true
  return false

func on_every_try(using_character, battlefield_characters):
  var target = using_character.get_closest_char(battlefield_characters)
  var direction = using_character.position.direction_to(target.position)
  $MeleeHitbox.rotation = direction.angle() - using_character.rotation

func _on_SlashAnimation_animation_finished():
  $MeleeHitbox/SlashAnimation.stop()
  $MeleeHitbox/SlashAnimation.frame = 4
  if cur_target != null:
    cur_target.update_health(-damage)
