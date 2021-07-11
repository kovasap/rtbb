extends Character

class_name Soldier

# https://github.com/godotengine/godot/issues/21789
func get_class_name(): return 'Soldier'

var Slash = load("res://characters/abilities/Slash.tscn")
func _ready():
  cost = 2
  max_health = 5
  faction_sprites = {
    'enemy': preload('res://sprites/chess/black_pawn.png'),
    'friendly': preload('res://sprites/chess/white_pawn.png'),
  }
  abilities.append(Slash.instance())
  add_synergy(Mercenary)
  ._ready()


func cross(base_character):
  base_character.add_synergy(Mercenary)
  base_character.update_max_health(base_character.max_health + 4)
  # You cannot scale RigidBody2Ds directly:
  # https://github.com/godotengine/godot/issues/5734
  base_character.get_node('Sprite').scale = Vector2(1.5, 1.5)
  base_character.get_node('Hitbox').scale = Vector2(1.5, 1.5)
  .cross(base_character)
