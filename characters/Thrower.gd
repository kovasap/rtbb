extends Character

class_name Thrower

# https://github.com/godotengine/godot/issues/21789
func get_class(): return 'Thrower'

func _ready():
  cost = 3
  max_health = 4
  projectile_speed = 1000
  attack_range = 3000
  attack_cooldown = 50
  attack_damage = 3
  faction_sprites = {
    'enemy': preload('res://sprites/chess/black_rook.png'),
    'friendly': preload('res://sprites/chess/white_rook.png'),
  }
  ._ready()

func try_attack(target_character):
  if self.position.distance_to(target_character.position) < attack_range:
    var direction = self.position.direction_to(target_character.position)
    shoot(direction)
    return true
  return false

onready var projectile_scene = load("res://Projectile.tscn")
var projectiles = []
func shoot(direction):
  var projectile = projectile_scene.instance()
  projectile.damage = attack_damage
  add_child(projectile)
  projectile.rotation = direction.angle() + PI/2
  projectile.linear_velocity = projectile_speed * direction
  projectiles.append(projectile)


func reset():
  for p in projectiles:
    remove_child(p)
  projectiles = []
  .reset()
