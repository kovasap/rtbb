extends Character

class_name Thrower

# https://github.com/godotengine/godot/issues/21789
func get_class_name(): return 'Thrower'

var Shoot = load("res://characters/abilities/Shoot.tscn")
func _ready():
  cost = 3
  max_health = 4
  speed = 0
  faction_sprites = {
    'enemy': preload('res://sprites/chess/black_knight.png'),
    'friendly': preload('res://sprites/chess/white_knight.png'),
  }
  abilities.append(Shoot.instance())
  add_synergy(Mercenary)
  ._ready()
