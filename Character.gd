extends Node2D

var color = Color(0, 1, 0, 1)
var velocity = 100

func get_closest_char(other_characters):
	var closest_dist = INF
	var closest_char
	for oc in other_characters:
		if oc == self:
			continue
		var dist = self.position.distance_to(oc.position)
		if dist < closest_dist:
			closest_dist = dist
			closest_char = oc
	return closest_char

# Find the closest character to me and go one velocity step towards it.
func move(other_characters):
	var closest_char = get_closest_char(other_characters)
	var direction = self.position.direction_to(closest_char.position)
	self.linear_velocity = velocity * direction


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	# We draw the circle at 0, 0 relative to THIS SCENE.
	draw_circle(Vector2(0,0), 20, color)
