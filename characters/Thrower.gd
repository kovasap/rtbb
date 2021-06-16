extends Character

class_name Thrower

func _ready():
  cost = 3
  max_health = 4
  projectile_speed = 1000
  fire_range = 3000
  attack_cooldown = 50
  ._ready()

func act(game):
  .act(game)
