extends Character

class_name Demolitionist

# https://github.com/godotengine/godot/issues/21789
func get_class_name(): return 'Demolitionist'

# var LayMine = load("res://characters/abilities/LayMine.tscn")
func _ready():
  cost = 3
  max_health = 4
  speed = 2
  faction_sprites = {
    'enemy': preload('res://sprites/chess/black_rook.png'),
    'friendly': preload('res://sprites/chess/white_rook.png'),
  }
  # TODO have this character lay mines
  # abilities.append(LayMine.instance())
  ._ready()


# TODO make base_character explode on death
func upgrade(base_character):
  pass
