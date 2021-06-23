extends Character

class_name Healer

# https://github.com/godotengine/godot/issues/21789
func get_class(): return 'Healer'

func _ready():
  cost = 3
  max_health = 6
  attack_damage = 1
  faction_sprites = {
    'enemy': preload('res://sprites/chess/black_king.png'),
    'friendly': preload('res://sprites/chess/white_king.png'),
  }
  $HealArea.color = Color(0, 1, 0, 0.1)
  $HealArea.health_delta_over_time = 1
  $HealArea.speed_modifier = 0.9
  $HealArea/CollisionShape2D.shape.radius = 100
  ._ready()


func _process(_delta):
  $HealArea.visible = not get_parent().paused

