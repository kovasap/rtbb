extends Ability

class_name SlowArea

var cur_target

var damage = 1
var projectile_speed = 50
var ability_range = 1000

func use(using_character, battlefield_characters):
  var target = using_character.get_closest_char(battlefield_characters)
  if using_character.position.distance_to(target.position) < ability_range:
    var direction = using_character.position.direction_to(target.position)
    shoot(direction)
    return true
  return false

onready var aoe_scene = load("res://characters/abilities/spawns/AreaOfEffect.tscn")
var projectiles = []
func shoot(direction):
  var aoe = aoe_scene.instance()
  aoe.speed_modifier = 0.2
  aoe.entry_health_delta = -damage
  add_child(aoe)
  aoe.rotation = direction.angle() + PI/2
  aoe.linear_velocity = projectile_speed * direction
  projectiles.append(aoe)


func reset():
  for p in projectiles:
    remove_child(p)
  projectiles = []
  .reset()
