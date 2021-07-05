extends Node2D

class_name Synergy

# Children should use AutoLoad to be accessible by character scenes:
# https://docs.godotengine.org/en/stable/getting_started/step_by_step/singletons_autoload.html


var images = [
  # preload('res://characters/synergies/base_0.png'),
  # preload('res://characters/synergies/base_1.png'),
  # preload('res://characters/synergies/base_2.png'),
  # preload('res://characters/synergies/base_3.png'),
  # preload('res://characters/synergies/base_4.png'),
  # preload('res://characters/synergies/base_5.png'),
  # preload('res://characters/synergies/base_6.png'),
]

# Number of characters required for this synergy to reach a certain level.
var num_chars_required = [3, 6]

# https://github.com/godotengine/godot/issues/21789
func get_class(): return 'Synergy'

func _ready():
  pass


func make_tile(faction):
  # Create the tile instance.
  var tile = load("res://characters/synergies/SynergyTile.tscn").instance()
  tile.synergy = self
  tile.update_image(faction)
  return tile


func get_num_chars(faction):
  var chars = Game.characters['party'] if faction == 'friendly' \
      else Game.characters['enemy']
  var unique_char_types = {}  # using this as a set here
  for c in chars:
    if self in c.synergies:
      unique_char_types[c.get_class()] = 1
  return unique_char_types.size()


# Get the level of this synergy based on how many party characters have it.
# 0 means the synergy is not active
func get_level(faction):
  var num_chars = get_num_chars(faction)
  for i in num_chars_required.size():
    if num_chars < num_chars_required[i]:
      return i


# Implemented by child classes
func update_character(c):
  pass


func update_syn(faction):
  var chars_to_update = Game.characters['party'] \
      if faction == 'friendly' else Game.characters['enemy']
  for c in chars_to_update:
    update_character(c)
    for t in c.get_node('Synergies').get_children():
      t.update_image(faction)

