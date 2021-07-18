# Main Game logic.  Can be accessed accross the project with the "Game" Autoloaded scene.

extends Node2D

const reroll_cost = 2
var gold = 10
var max_party_size = 4
var shop_open = false
var hovering_over_bench = false
var hovering_over_ui = false
var dragging_character = false

var cur_level = 0
var characters = {
  'pool': [],
  'shop': [],
  'party': [],
  'enemy': [],
  'bench': [],
}

onready var all_synergies = [Mercenary]

func get_battlefield_characters():
  return characters['party'] + characters['enemy']

# Pass 'null' to delete the character (e.g. when combining it into a higher tier unit).
func move_character(character, new_location):
  for location in characters:
    characters[location].erase(character)
  if new_location == null:
    remove_child(character)
    character.queue_free()
  else:
    characters[new_location].append(character)
  if new_location == 'party':
    for s in all_synergies:
      s.update_syn('friendly')
  elif new_location == 'enemy':
    for s in all_synergies:
      s.update_syn('enemy')
  # Synergies.apply_synergies(characters['party'])
  # $ShopGUI.update_synergies(Synergies.get_synergy_levels(characters['party']))

func move_all_characters(source, dest):
  # Done so we don't iterate over an array we are deleting elements from.
  var source_array = characters[source].duplicate()
  for c in source_array:
    move_character(c, dest)


# Control for the window of time after a battle ends before the shop opens.
const battle_ending_duration = 100  # frames
var battle_ending_time_elapsed = 0  # frames
var battle_ending = false

var paused = true

# onready var Synergies = preload("res://characters/Synergies.gd").new()

onready var char_scenes = {
  'Soldier': load("res://characters/Soldier.tscn"),
  'Thrower': load("res://characters/Thrower.tscn"),
  'Mystic': load("res://characters/Mystic.tscn"),
  'Healer': load("res://characters/Healer.tscn"),
  'Assassin': load("res://characters/Assassin.tscn"),
}
func make_character(pos, faction, type):
  var character = char_scenes[type].instance()
  add_child(character)
  character.set_start_position(pos)
  character.set_faction(faction)
  return character


const shop_pool = {
  'Soldier': 10,
  'Thrower': 5,
  'Mystic': 5,
  'Healer': 5,
  'Assassin': 5,
}

func build_shop_pool():
  for char_type in shop_pool:
    for _i in range(shop_pool[char_type]):
      var pool_character = make_character(Vector2(0, 0), 'friendly', char_type)
      pool_character.hide_and_disable()
      characters['pool'].append(pool_character)


func buy_character(c):
  gold -= c.cost
  move_character(c, 'party')
  $CanvasLayer/ShopGUI.update()
  c.in_shop = false

func setup_debug_scenerio():
  var friendly = make_character(Vector2(300, 300), 'friendly', 'Assassin')
  var enemy = make_character(Vector2(700, 300), 'enemy', 'Soldier')
  characters['party'] = [friendly]
  characters['enemy'] = [enemy]

# Called when the node enters the scene tree for the first time.
func _ready():
  build_shop_pool()
  # setup_debug_scenerio()
  var friendly = make_character(Vector2(400, 180), 'friendly', 'Soldier')
  characters['party'].append(friendly)
  Levels.load_level(cur_level)
  $CanvasLayer/ShopGUI.open_shop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
  if not paused:
    for character in get_battlefield_characters():
      character.act()

  if battle_ending:
    battle_ending_time_elapsed += 1
    if battle_ending_time_elapsed > battle_ending_duration:
      $CanvasLayer/ShopGUI.open_shop()
      if not Levels.load_level(cur_level):
        $CanvasLayer/ResultAnnouncement.text = 'You win!!'
      battle_ending = false
      Engine.time_scale = 1.0
      $Camera2D.scroll_to_next_level()
  else:
    var battle_won = true
    var battle_lost = true
    for c in characters['party']:
      if not c.dead:
        battle_lost = false
    for c in characters['enemy']:
      if not c.dead:
        battle_won = false
    if battle_won or battle_lost:
      Engine.time_scale = 0.1
      if battle_won:
        $CanvasLayer/ResultAnnouncement.text = 'Battle %s Won!' % cur_level
        cur_level += 1
      if battle_lost:
        $CanvasLayer/ResultAnnouncement.text = 'Battle %s Lost, Try Again!' % cur_level
      $CanvasLayer/ResultAnnouncement.visible = true
      battle_ending = true

func _on_Button_pressed():
  $CanvasLayer/ShopGUI.close_shop()
