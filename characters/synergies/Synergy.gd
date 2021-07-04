extends Node2D

class_name Synergy

# Children should use AutoLoad to be accessible by character scenes:
# https://docs.godotengine.org/en/stable/getting_started/step_by_step/singletons_autoload.html


var tile_instances_by_faction = {
  'friendly': [],
  'enemy': [],
}
var images = [
  # preload('res://characters/synergies/base_0.png'),
  # preload('res://characters/synergies/base_1.png'),
  # preload('res://characters/synergies/base_2.png'),
  # preload('res://characters/synergies/base_3.png'),
  # preload('res://characters/synergies/base_4.png'),
  # preload('res://characters/synergies/base_5.png'),
  # preload('res://characters/synergies/base_6.png'),
  # TODO remove
  preload('res://characters/synergies/mercenary_0.png'),
  preload('res://characters/synergies/mercenary_1.png'),
  preload('res://characters/synergies/mercenary_2.png'),
  preload('res://characters/synergies/mercenary_3.png'),
  preload('res://characters/synergies/mercenary_4.png'),
]

# Number of characters required for this synergy to reach a certain level.
var num_chars_required = [3, 6]

# https://github.com/godotengine/godot/issues/21789
func get_class(): return 'Synergy'


func _ready():
  print('SYN READY')


func make_tile(faction):
  # Create the tile instance.
  var tile = load("res://characters/synergies/SynergyTile.tscn").instance()
  tile_instances_by_faction[faction].append(tile)
  tile.get_node('Symbol').set_texture(images[get_num_chars(faction)])
  return tile


func get_num_chars(faction):
  var num_chars = 0
  var chars = Game.characters['party'] if faction == 'friendly' \
      else Game.characters['enemy']
  for c in chars:
    if self in c.synergies:
      num_chars += 1
  return num_chars


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
  for t in tile_instances_by_faction[faction]:
    if t:
      t.get_node('Symbol').set_texture(images[get_num_chars(faction)])
  for c in Game.characters['party']:
    update_character(c)

