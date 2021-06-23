extends Character

class_name Mystic

# https://github.com/godotengine/godot/issues/21789
func get_class(): return 'Mystic'

func _ready():
  cost = 4
  max_health = 3
  projectile_speed = 100
  attack_range = 3000
  attack_cooldown = 500
  attack_damage = 1
  faction_sprites = {
    'enemy': preload('res://sprites/chess/black_bishop.png'),
    'friendly': preload('res://sprites/chess/white_bishop.png'),
  }
  ._ready()

func try_attack(target_character):
  if self.position.distance_to(target_character.position) < attack_range:
    var direction = self.position.direction_to(target_character.position)
    shoot(direction)
    return true
  return false

onready var aoe_scene = load("res://AreaOfEffect.tscn")
var projectiles = []
func shoot(direction):
  var aoe = aoe_scene.instance()
  aoe.speed_modifier = 0.2
  aoe.entry_health_delta = -attack_damage
  add_child(aoe)
  aoe.rotation = direction.angle() + PI/2
  aoe.linear_velocity = projectile_speed * direction
  projectiles.append(aoe)


func reset():
  for p in projectiles:
    remove_child(p)
  projectiles = []
  .reset()
