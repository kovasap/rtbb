extends Ability

class_name Shoot

var cur_target

var damage = 1
var projectile_speed = 1000
var ability_range = 1000

func _ready():
  cooldown = 200


func use(using_character, battlefield_characters):
  var target = using_character.get_closest_char(battlefield_characters)
  if using_character.position.distance_to(target.position) < ability_range:
    var direction = using_character.position.direction_to(target.position)
    shoot(direction)
    return true
  return false

onready var projectile_scene = load("res://characters/abilities/spawns/Projectile.tscn")
var projectiles = []
func shoot(direction):
  var projectile = projectile_scene.instance()
  projectile.damage = damage
  add_child(projectile)
  projectile.rotation = direction.angle() + PI/2
  projectile.linear_velocity = projectile_speed * direction
  projectiles.append(projectile)

func reset():
  for p in projectiles:
    remove_child(p)
  projectiles = []
  .reset()
