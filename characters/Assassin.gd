extends Character

class_name Assassin

# https://github.com/godotengine/godot/issues/21789
func get_class_name(): return 'Assassin'

var Slash = load("res://characters/abilities/Slash.tscn")
var Teleport = load("res://characters/abilities/Teleport.tscn")
func _ready():
  cost = 2
  max_health = 2
  faction_sprites = {
    'enemy': preload('res://sprites/chess/black_queen.png'),
    'friendly': preload('res://sprites/chess/white_queen.png'),
  }
  abilities.append(Teleport.instance())
  abilities.append(Slash.instance())
  ._ready()

onready var ShadowShader = preload('res://shaders/dropshadow.shader')

func upgrade(base_character):
  var teleport = Teleport.instance()
  base_character.abilities.push_front(teleport)
  base_character.add_child(teleport)
  base_character.get_node('Sprite').material = ShaderMaterial.new()
  base_character.get_node('Sprite').material.shader = ShadowShader
  .upgrade(base_character)

