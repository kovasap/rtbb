extends Node2D

const reroll_cost = 2
var gold = 10
var shop_open = false
var hovering_over_bench = false

var cur_level = -1
# Each level describes enemy positions for that level.
# TODO give this better structure.
const levels = [
  # [Vector2(700, 200)],
  [Vector2(700, 200), Vector2(700, 300)],
  [Vector2(700, 200), Vector2(700, 300), Vector2(700, 100)],
  [Vector2(700, 200), Vector2(700, 300), Vector2(700, 100),
   Vector2(850, 200), Vector2(850, 300), Vector2(850, 100)],
]

var characters = {
  'pool': [],
  'shop': [],
  'party': [],
  'enemy': [],
  'bench': [],
}

func get_battlefield_characters():
  return characters['party'] + characters['enemy']

# Pass 'null' to delete the character (e.g. when combining it into a higher tier unit).
func move_character(character, new_location):
  for loc in characters:
    characters[loc].erase(character)
  if new_location == null:
    remove_child(character)
    character.queue_free()
  else:
    characters[new_location].append(character)


# Control for the window of time after a battle ends before the shop opens.
const battle_ending_duration = 100  # frames
var battle_ending_time_elapsed = 0  # frames
var battle_ending = false

var paused = true

onready var Synergies = preload("res://characters/Synergies.gd").new()

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
  'Soldier': 1,
  'Thrower': 1,
  'Mystic': 1,
  'Healer': 1,
  'Assassin': 10,
}

func build_shop_pool():
  for char_type in shop_pool:
    for _i in range(shop_pool[char_type]):
      var pool_character = make_character(Vector2(0, 0), 'friendly', char_type)
      pool_character.visible = false
      characters['pool'].append(pool_character)

func load_next_level():
  for c in characters['enemy']:
    move_character(c, null)
  for c in characters['party']:
    c.reset()
  cur_level += 1
  if cur_level >= 2:
    cur_level = 2
  for enemy_position in levels[cur_level]:
    var enemy = make_character(enemy_position, 'enemy', 'Soldier')
    characters['enemy'].append(enemy)

func buy_character(c):
  gold -= c.cost
  characters['party'].append(c)
  $ShopGUI.update()
  c.in_shop = false
  Synergies.apply_synergies(characters['party'])
  $ShopGUI.update_synergies(Synergies.get_synergy_levels(characters['party']))

func setup_debug_scenerio():
  var friendly = make_character(Vector2(300, 300), 'friendly', 'Assassin')
  var enemy = make_character(Vector2(700, 300), 'enemy', 'Soldier')
  characters['party'] = [friendly]
  characters['enemy'] = [enemy]

# Called when the node enters the scene tree for the first time.
func _ready():
  build_shop_pool()
  setup_debug_scenerio()
  # var friendly = make_character(Vector2(400, 180), 'friendly', 'Soldier')
  # characters['party'].append(friendly)
  # load_next_level()
  $ShopGUI.open_shop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
  if not paused:
    for character in get_battlefield_characters():
      character.act()

  if battle_ending:
    battle_ending_time_elapsed += 1
    if battle_ending_time_elapsed > battle_ending_duration:
      $ShopGUI.open_shop()
      load_next_level()
      battle_ending = false
      Engine.time_scale = 1.0
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
        $ResultAnnouncement.text = 'Battle %s Won!' % cur_level
      if battle_lost:
        $ResultAnnouncement.text = 'Battle %s Lost!' % cur_level
      $ResultAnnouncement.visible = true
      battle_ending = true

func _on_Button_pressed():
  $ShopGUI.close_shop()
