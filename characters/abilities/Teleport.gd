extends Ability

class_name Teleport

func get_class_name(): return 'Teleport'

func use(using_character, battlefield_characters):
  var furthest_char = using_character.get_furthest_char(battlefield_characters)
  var direction = using_character.position.direction_to(furthest_char.position)
  using_character.position = furthest_char.position + 50 * direction
