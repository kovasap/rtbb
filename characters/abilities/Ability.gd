extends Node2D

class_name Ability

var cooldown = 100
var time_until_next_use = 0

var stats_to_describe = ['cooldown']

func _ready():
  pass

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

func get_class_name(): return 'Ability'

# Creates a control node describing this ability
func generate_description():
  var description = VBoxContainer.new()
  var name = RichTextLabel.new()
  name.text = get_class_name()
  name.rect_min_size = Vector2(0, 20)
  description.add_child(name)
  for stat in stats_to_describe:
    var stat_desc = RichTextLabel.new()
    stat_desc.text = '    %s: %s' % [stat, get(stat)]
    stat_desc.rect_min_size = Vector2(0, 20)
    description.add_child(stat_desc)
  return description
