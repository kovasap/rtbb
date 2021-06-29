extends Node2D

class_name Ability

var cooldown = 100
var time_until_next_use = 0

# Returns if ability was used or not
func try_to_use(using_character, battlefield_characters) -> bool:
  on_every_try(using_character, battlefield_characters)
  if time_until_next_use <= 0:
    time_until_next_use = cooldown
    return use(using_character, battlefield_characters)
  time_until_next_use -= 1
  return false

# Implemented by subclasses.  Returns if ability was used or not.
func use(_using_character, _battlefield_characters) -> bool:
  return false

func on_every_try(_using_character, _battlefield_characters):
  pass

func reset():
  pass
