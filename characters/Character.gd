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
var crosses = []

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
var crossing_with = null
var cur_velocity = Vector2(0, 0)
var hovering = false

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
  if dead or Game.dragging_character:
    return
  var closest_opponent = get_closest_char(Game.get_battlefield_characters())
  if closest_opponent == null:
    self.linear_velocity = Vector2(0, 0)
    return
  var direction = self.position.direction_to(closest_opponent.position)
  # This CANNOT be used to rotate the body - will glitch out movement
  # See
  # https://godotengine.org/qa/107669/rigidbody2d-will-not-move-when-it-has-an-area2d-as-a-child
  # self.rotation = direction.angle()
  # Use of sin here gradually corrects angular_velocity to zero as the
  # difference between the current rotation and the angle_to_normalize_to goes
  # to zero.
  var angle_to_normalize_to = 0  # direction.angle()
  self.angular_velocity = 40 * sin((angle_to_normalize_to - self.rotation) / 10)
  var closest_char = get_closest_char(Game.get_battlefield_characters(), false)
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
    ability.try_to_use(self, Game.get_battlefield_characters())

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
    # Snap locations to the battlefield grid.
    var mouse_pos = get_viewport().get_mouse_position()
    set_start_position(
      Game.get_node("Battlefield").world_to_tile_coordinates(
        mouse_pos, true))

func _draw():
  # We draw the circle at 0, 0 relative to THIS SCENE.
  # draw_circle(Vector2(0,0), 20, color)
  pass

func _on_Character_body_entered(body):
  if body.get('is_character'):
    if body.dragging:
      crossing_with = body
    elif dragging:
      body.crossing_with = self
    else:
      pass  # No merging

func _on_Character_body_exited(body):
  if body.get('is_character'):
    crossing_with = null

# Make modifications to base character based on what this character is.
# Overridden by child classes.
func cross(base_character):
  base_character.crosses.append(get_class_name())

# Overridden by child classes.
func get_class_name(): return 'Character'

# TODO show the effect of a potential cross in this window when dragging one
# character over another
func update_stats_panel():
  $StatsPanel/VBox/Class.text = get_class_name()
  $StatsPanel/VBox/Crosses.text = PoolStringArray(crosses).join(' x')
  $StatsPanel/VBox/Stats.text = PoolStringArray([
    'Speed: %s' % speed,
    'Max Health: %s' % max_health,
  ]).join('\n')
  # TODO cache the result instead of creating every time.
  for c in $StatsPanel/VBox/Abilities.get_children():
    $StatsPanel/VBox/Abilities.remove_child(c)
    c.queue_free()
  for a in abilities:
    $StatsPanel/VBox/Abilities.add_child(a.generate_description())

func show_stats_panel():
  update_stats_panel()
  $StatsPanel.visible = true

func hide_stats_panel():
  $StatsPanel.visible = false

func drop():
  Game.dragging_character = false
  dragging = false
  if crossing_with:
    crossing_with.cross(self)
    print('upgrading %s with %s' % [get_class_name(), crossing_with.get_class_name()])
    crossing_with.hide_and_disable()
    Game.move_character(crossing_with, null)

func _on_Character_input_event(_viewport, event, _shape_idx):
  if event is InputEventMouseButton:
    if event.button_index == BUTTON_LEFT:
      if faction == 'enemy':
        print('cannot interact with enemy units!')
        return
      if dragging:
        if Game.hovering_over_ui:
          print('cannot drop character onto ui element!')
        else:
          if Game.hovering_over_bench:
            Game.move_character(self, 'bench')
          drop()
      elif event.pressed:
        Game.dragging_character = true
        dragging = true

func _on_Character_input_event_shop(event):
  if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
    if event.pressed:
      if Game.dragging_character:
        print('cannot buy when moving a character!')
      else:
        if Game.gold < cost:
          print('not enough money!')
        elif not in_shop:
          print('character not in shop!')
        else:
          Game.buy_character(self)
          _on_Character_input_event(null, event, null)

func _on_Character_mouse_entered():
  hovering = true
  show_stats_panel()

func _on_Character_mouse_exited():
  hovering = false
  hide_stats_panel()
