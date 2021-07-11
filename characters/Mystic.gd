extends Character

class_name Mystic

# https://github.com/godotengine/godot/issues/21789
func get_class_name(): return 'Mystic'

var SlowArea = load("res://characters/abilities/SlowArea.tscn")
func _ready():
  cost = 4
  max_health = 3
  projectile_speed = 100
  faction_sprites = {
    'enemy': preload('res://sprites/chess/black_bishop.png'),
    'friendly': preload('res://sprites/chess/white_bishop.png'),
  }
  abilities.append(SlowArea.instance())
  ._ready()

