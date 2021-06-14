extends Node2D

var color = Color(0, 1, 0, 1)
var faction = 'friendly'
var velocity = 50

var health = 5
const max_health = 5
var hearts = []
var dead = false

# If two characters are this far apart they are considered adjacent and will not move towards each other anymore.
const adjacency_distance = 50

# Projectile stuff
var fire_range = 3000
var rate_of_fire = 100
var cooldown = 0

# Drag and drop character
# https://generalistprogrammer.com/godot/godot-drag-and-drop-tutorial/
var dragging = false
signal dragsignal;

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

# Find the closest character to me and go one velocity step towards it.
func act(game):
	if dead or dragging:
		return
	var closest_char = get_closest_char(game.characters)
	if closest_char == null:
		self.linear_velocity = Vector2(0, 0)
		return
	var direction = self.position.direction_to(closest_char.position)
	var distance = self.position.distance_to(closest_char.position)
	if distance > adjacency_distance:
		self.linear_velocity = velocity * direction
	else:
		self.linear_velocity = Vector2(0, 0)
	if distance < fire_range:
		if cooldown == 0:
			shoot(direction)
			cooldown = rate_of_fire
		else:
			cooldown -= 1

onready var projectile_scene = load("res://Projectile.tscn")
func shoot(direction):
	var projectile = projectile_scene.instance()
	add_child(projectile)
	projectile.rotation = direction.angle() + PI/2
	projectile.linear_velocity = 400 * direction


func _ready():
	connect("dragsignal", self, "_set_drag_pc")
	for i in range(max_health):
		var heart = Sprite.new()
		heart.texture = load("res://item_sprites/16x16 RPG Item Pack/Item__29.png")
		add_child(heart)
		heart.position = Vector2(10 * i - 30, -30)
		hearts.append(heart)


func update_health(delta):
	health += delta
	for i in hearts.size():
		if i < health:
			hearts[i].visible = true
		else:
			hearts[i].visible = false
	if health <= 0:
		$CollisionShape2D.disabled = true
		self.linear_velocity = Vector2(0, 0)
		$Sprite.modulate.a = 0.4
		dead = true

func _process(delta):
	if dragging:
		var mousepos = get_viewport().get_mouse_position()
		self.position = Vector2(mousepos.x, mousepos.y)

func _draw():
	# We draw the circle at 0, 0 relative to THIS SCENE.
	# draw_circle(Vector2(0,0), 20, color)
	pass

const Projectile = preload("Projectile.gd")
func _on_Character_body_entered(body):
	# TODO Figure out how to have projectiles stick into the character and stay
	if body is Projectile:
		update_health(-body.damage)
		body.collision_layer = 0
		add_child(body)
		body.get_node("CollisionShape2D").disabled = true
		body.stuck = true
		body.set_owner(self)

func _set_drag_pc():
	dragging = !dragging

func _on_Character_input_event(viewport, event, shape_idx):
	print(event)
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("dragsignal")
		elif event.button_index == BUTTON_LEFT and !event.pressed:
			emit_signal("dragsignal")
