extends Area2D


var speed_modifier = 1.0
var entry_health_delta = 0
var exit_health_delta = 0
var health_delta_over_time = 0
var health_delta_over_time_frequency = 5
var health_delta_over_time_cooldown = 0
var linear_velocity = Vector2(0, 0)
var color = Color(0, 0, 1, 0.4)
var color_is_flashing = false
var color_flash_duration = 0.2
var color_flash_cooldown = 0
var color_flash_alpha = 0.1
var inside_characters = []


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  if not get_parent().visible:
    return
  position += delta * linear_velocity
  health_delta_over_time_cooldown += delta
  if (health_delta_over_time_cooldown > health_delta_over_time_frequency
      and inside_characters.size() > 0):
    for c in inside_characters:
      c.update_health(health_delta_over_time)
    color.a += color_flash_alpha
    update()
    color_flash_cooldown = 0
    color_is_flashing = true
    health_delta_over_time_cooldown = 0
  if color_is_flashing:
    color_flash_cooldown += delta
    if color_flash_cooldown > color_flash_duration:
      color.a -= color_flash_alpha
      update()
      color_flash_cooldown = 0
      color_is_flashing = false


func _draw():
  # We draw the circle at 0, 0 relative to THIS SCENE.
  draw_circle(Vector2(0,0), $CollisionShape2D.shape.radius, color)


func _on_Node2D_body_entered(body):
  if body is Character:
    inside_characters.append(body)
    body.speed_modifier = speed_modifier
    body.update_health(entry_health_delta)


func _on_Node2D_body_exited(body):
  if body is Character:
    inside_characters.erase(body)
    body.speed_modifier = 1.0
    body.update_health(exit_health_delta)
