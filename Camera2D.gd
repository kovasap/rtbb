extends Camera2D

const move_amount = 50
const speed = 800
var scrolling = false
var distance_scrolled = 0
const page_size = 850

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.

func scroll_to_next_level():
  scrolling = true

func _process(delta):
  if scrolling:
    var distance = speed * delta
    position += Vector2(distance, 0)
    distance_scrolled += distance
  if distance_scrolled > page_size:
    scrolling = false
    distance_scrolled = 0

func _input(event):
  if event is InputEventKey and event.pressed:
    var key = OS.get_scancode_string(event.scancode)
    if key == 'Left':
      position += Vector2(-move_amount, 0)
    elif key == 'Right':
      position += Vector2(move_amount, 0)
    elif key == 'Up':
      position += Vector2(0, -move_amount)
    elif key == 'Down':
      position += Vector2(0, move_amount)
    elif key == 'Space':
      scrolling = true
