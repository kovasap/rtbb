extends RigidBody2D

class_name Character

# Character stats
var speed = 50
var speed_modifier = 1.0
var cost = 2
var max_health = 5
var color = Color(0, 1, 0, 1)
var faction = 'friendly'
var projectile_speed = 400
# If two characters are this far apart they are considered adjacent and will
# not move towards each other anymore.
var adjacency_distance = 65
var faction_sprites = {
  'enemy': preload('res://sprites/chess/black_pawn.png'),
  'friendly': preload('res://sprites/chess/white_pawn.png'),
}
const faction_colors = {
  'enemy': Color(1, 0, 0, 1),
  'friendly': Color(0, 1, 0, 1),
}
var abilities = []
var synergies = []

# https://github.com/godotengine/godot/issues/21461
# Used to check if the instance in question is a character (e.g. for Projectile
# collisions).
const is_character = true
# Internal logic vars common to all characters.
var in_shop = false
var start_position = Vector2(0, 0)
var health
var hearts = []
var dead = false
var dragging = false
var merging_with = null
var cur_velocity = Vector2(0, 0)

func hide_and_disable():
  visible = false
  $CollisionShape2D.disabled = true

func show_and_enable():
  visible = true
  $CollisionShape2D.disabled = false

func add_synergy(new_synergy):
  if !synergies.has(new_synergy):
    synergies.append(new_synergy)
    $Synergies.add_child(new_synergy.make_tile(faction))
    new_synergy.update_character(self)

# TODO have health be represented by cracks on the pieces (more cracks -> less
# remaining health) instead of by these "hearts".
func update_max_health(new_max):
  max_health = new_max
  health = max_health
  for h in hearts:
    remove_child(h)
    h.queue_free()
  hearts = []
  for i in range(max_health):
    var heart = Sprite.new()
    heart.texture = load("res://sprites/16x16 RPG Item Pack/Item__29.png")
    add_child(heart)
    heart.position = Vector2(10 * i - 30, -30)
    hearts.append(heart)

func _ready():
  update_max_health(max_health)
  for a in abilities:
    add_child(a)

func set_faction(new_faction):
  faction = new_faction
  color = faction_colors[faction]
  $Sprite.set_texture(faction_sprites[faction])

func set_start_position(new_start_position):
  # Setting position does not work because the physics engine will recompute
  # location as the original location every timestep.
  global_transform.origin = new_start_position
  start_position = new_start_position

func get_closest_char(other_characters, of_different_faction = true):
  var closest_dist = INF
  var closest_char = null
  for oc in other_characters:
    if oc == self or oc.dead:
      continue
    if of_different_faction and oc.faction == faction:
      continue
    var dist = self.position.distance_to(oc.position)
    if dist < closest_dist:
      closest_dist = dist
      closest_char = oc
  return closest_char

func get_furthest_char(other_characters):
  var furthest_dist = 0
  var furthest_char = null
  for oc in other_characters:
    if oc == self or oc.dead or oc.faction == faction:
      continue
    var dist = self.position.distance_to(oc.position)
    if dist > furthest_dist:
      furthest_dist = dist
      furthest_char = oc
  return furthest_char

# Find the closest character to me and go one speed step towards it.  Attack if
# possible.
func act():
  if dead or get_parent().dragging_character:
    return
  var closest_opponent = get_closest_char(get_parent().get_battlefield_characters())
  if closest_opponent == null:
    self.linear_velocity = Vector2(0, 0)
    return
  var direction = self.position.direction_to(closest_opponent.position)
  # This CANNOT be used to rotate the body - will glitch out movement
  # See
  # https://godotengine.org/qa/107669/rigidbody2d-will-not-move-when-it-has-an-area2d-as-a-child
  # self.rotation = direction.angle()
  # Use of sin here gradually corrects angular_velocity to zero as the
  # difference between the current rotation and the angle to the closest
  # character goes to zero.
  # self.angular_velocity = 40 * sin((direction.angle() - self.rotation) / 10)
  var closest_char = get_closest_char(get_parent().get_battlefield_characters(), false)
  var closest_char_distance = self.position.distance_to(closest_char.position)
  var closest_char_direction = self.position.direction_to(closest_char.position)
  # If there is a character that is adjacency_distance away from me and in the
  # direction I want to go, then I wait for it to move.
  if (closest_char_distance > adjacency_distance
      or (closest_char != closest_opponent
          and abs(closest_char_direction.angle() - direction.angle()) > PI/2)):
    self.linear_velocity = speed_modifier * speed * direction
  else:
    self.linear_velocity = Vector2(0, 0)
  for ability in abilities:
    ability.try_to_use(self, get_parent().get_battlefield_characters())

# func _integrate_forces(state):
#   state.set_linear_velocity(cur_velocity)

func die():
  $CollisionShape2D.disabled = true
  $Hitbox/CollisionShape2D.disabled = true
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
  for a in abilities:
    a.reset()

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

func _on_Character_body_entered(body):
  if body.get('is_character'):
    if body.dragging:
      merging_with = body
    elif dragging:
      body.merging_with = self
    else:
      pass  # No merging

func _on_Character_body_exited(body):
  if body.get('is_character'):
    merging_with = null

# Make modifications to base character based on what this character is.
func upgrade(_base_character):
  pass

func drop():
  get_parent().dragging_character = false
  dragging = false
  if merging_with:
    merging_with.upgrade(self)
    print('upgrading %s with %s' % [get_class(), merging_with.get_class()])
    merging_with.hide_and_disable()
    get_parent().move_character(merging_with, null)

func _on_Character_input_event(_viewport, event, _shape_idx):
  if event is InputEventMouseButton:
    if event.button_index == BUTTON_LEFT:
      if faction == 'enemy':
        print('cannot interact with enemy units!')
        return
      if dragging:
        if get_parent().hovering_over_ui:
          print('cannot drop character onto ui element!')
        else:
          if get_parent().hovering_over_bench:
            get_parent().move_character(self, 'bench')
          drop()
      elif event.pressed:
        get_parent().dragging_character = true
        dragging = true

func _on_Character_input_event_shop(event):
  if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
    if event.pressed:
      if get_parent().dragging_character:
        print('cannot buy when moving a character!')
      else:
        if get_parent().gold < cost:
          print('not enough money!')
        elif not in_shop:
          print('character not in shop!')
        else:
          get_parent().buy_character(self)
          _on_Character_input_event(null, event, null)
