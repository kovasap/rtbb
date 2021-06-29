extends Character

class_name Soldier

# https://github.com/godotengine/godot/issues/21789
func get_class(): return 'Soldier'

var Slash = load("res://characters/abilities/Slash.tscn")
func _ready():
  cost = 2
  max_health = 5
  faction_sprites = {
    'enemy': preload('res://sprites/chess/black_pawn.png'),
    'friendly': preload('res://sprites/chess/white_pawn.png'),
  }
  abilities.append(Slash.instance())
  ._ready()
