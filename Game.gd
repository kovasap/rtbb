extends Node2D


var characters = []

onready var char_scene = load("res://Character.tscn")
func make_character(pos, color):
	var character = char_scene.instance()
	add_child(character)
	character.position = pos
	character.color = color
	characters.append(character)
	return character

# Called when the node enters the scene tree for the first time.
func _ready():
	var friendly = make_character(Vector2(50, 50), Color(0, 1, 0, 1))
	var friendly2 = make_character(Vector2(50, 100), Color(0, 1, 0, 1))
	var enemy = make_character(Vector2(500, 50), Color(1, 0, 0, 1))
	var enemy2 = make_character(Vector2(250, 250), Color(1, 0, 0, 1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for character in characters:
		character.move(characters)
