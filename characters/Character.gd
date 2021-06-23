extends RigidBody2D

class_name Character

# Internal logic vars common to all characters.
var in_shop = false
var start_position = Vector2(0, 0)
var health
var hearts = []
var dead = false
var dragging = false
var time_until_next_attack = 0
var cur_velocity = Vector2(0, 0)
var cur_target

# Character stats
var speed = 50
var speed_modifier = 1.0
var cost = 2
var max_health = 5
var color = Color(0, 1, 0, 1)
var faction = 'friendly'
var projectile_speed = 400
var attack_range = 10
var attack_cooldown = 100
var attack_damage = 2
# If two characters are this far apart they are considered adjacent and will
# not move towards each other anymore.
var adjacency_distance = 75
var faction_sprites = {
  'enemy': preload('res://sprites/chess/black_pawn.png'),
  'friendly': preload('res://sprites/chess/white_pawn.png'),
}
const faction_colors = {
  'enemy': Color(1, 0, 0, 1),
  'friendly': Color(0, 1, 0, 1),
}

func _ready():
  health = max_health
  for i in range(max_health):
    var heart = Sprite.new()
    heart.texture = load("res://sprites/16x16 RPG Item Pack/Item__29.png")
    add_child(heart)
    heart.position = Vector2(10 * i - 30, -30)
    hearts.append(heart)

func set_faction(new_faction):
  faction = new_faction
  color = faction_colors[faction]
  $Sprite.set_texture(faction_sprites[faction])

func set_start_position(new_start_position):
  # Setting position does not work because the physics engine will recompute
  # location as the original location every timestep.
  global_transform.origin = new_start_position
  start_position = new_start_position

func get_closest_char(other_characters):
  var closest_dist = INF
  var closest_char = null
  for oc in other_characters:
    if oc == self or oc.dead or oc.faction == faction:
      continue
    var dist = self.position.distance_to(oc.position)
    if dist < closest_dist:
      closest_dist = dist
      closest_char = oc
  return closest_char

# Find the closest character to me and go one speed step towards it.  Attack if
# possible.
func act(game):
  if dead or dragging:
    return
  var closest_char = get_closest_char(game.battlefield_characters)
  if closest_char == null:
    self.linear_velocity = Vector2(0, 0)
    return
  var direction = self.position.direction_to(closest_char.position)
  # This CANNOT be used to rotate the body - will glitch out movement
  # See
  # https://godotengine.org/qa/107669/rigidbody2d-will-not-move-when-it-has-an-area2d-as-a-child
  # self.rotation = direction.angle()
  # Use of sin here gradually corrects angular_velocity to zero as the
  # difference between the current rotation and the angle to the closest
  # character goes to zero.
  # self.angular_velocity = 40 * sin((direction.angle() - self.rotation) / 10)
  $MeleeHitbox.rotation = direction.angle() - self.rotation
  var distance = self.position.distance_to(closest_char.position)
  if distance > adjacency_distance and distance > attack_range:
    self.linear_velocity = speed_modifier * speed * direction
  else:
    self.linear_velocity = Vector2(0, 0)
  if time_until_next_attack <= 0 and try_attack(closest_char):
      time_until_next_attack = attack_cooldown
  time_until_next_attack -= 1

# func _integrate_forces(state):
#   state.set_linear_velocity(cur_velocity)

# Implemented by subclasses.
func try_attack(_target_character):
  pass

func die():
  $CollisionShape2D.disabled = true
  self.linear_velocity = Vector2(0, 0)
  $Sprite.modulate.a = 0.4
  dead = true

func reset():
  $CollisionShape2D.disabled = false
  self.linear_velocity = Vector2(0, 0)
  $Sprite.modulate.a = 1.0
  dead = false
  position = start_position
  visible = true
  health = max_health
  rotation_degrees = 0
  update_health(0)

func update_health(delta):
  health += delta
  for i in hearts.size():
    if i < health:
      hearts[i].visible = true
    else:
      hearts[i].visible = false
  if health <= 0:
    die()

func _process(_delta):
  if dragging:
    set_start_position(get_viewport().get_mouse_position())

func _draw():
  # We draw the circle at 0, 0 relative to THIS SCENE.
  # draw_circle(Vector2(0,0), 20, color)
  pass

const Projectile = preload("res://Projectile.gd")
func _on_Character_body_entered(body):
  # TODO Figure out how to have projectiles stick into the character and stay
  if body is Projectile and body.get_parent() != self:
    update_health(-body.damage)
    body.collision_layer = 0
    add_child(body)
    body.get_node("CollisionShape2D").disabled = true
    body.stuck = true
    body.set_owner(self)

func _on_Character_input_event(_viewport, event, _shape_idx):
  if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
    if event.pressed:
      dragging = true
    elif !event.pressed:
      dragging = false

func _on_Character_input_event_shop(event):
  if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
    if event.pressed:
      if get_parent().gold >= cost:
        get_parent().buy_character(self)
        _on_Character_input_event(null, event, null)
      else:
        print('not enough money!')
