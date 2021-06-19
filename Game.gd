extends Node2D

const reroll_cost = 2
var gold = 10
var shop_open = false

var cur_level = -1
# Each level describes enemy positions for that level.
# TODO give this better structure.
const levels = [
  [Vector2(700, 200)],
  [Vector2(700, 200)],
  [Vector2(700, 200), Vector2(700, 300), Vector2(700, 100)],
  [Vector2(700, 200), Vector2(700, 300), Vector2(700, 100),
   Vector2(850, 200), Vector2(850, 300), Vector2(850, 100)],
]

var character_pool = []

var party_characters = []

# Control for the window of time after a battle ends before the shop opens.
const battle_ending_duration = 100  # frames
var battle_ending_time_elapsed = 0  # frames
var battle_ending = false

var paused = true
var battlefield_characters = []

onready var char_scenes = {
  'Character': load("res://characters/Character.tscn"),
  'Thrower': load("res://characters/Thrower.tscn"),
  'Mystic': load("res://characters/Mystic.tscn"),
}
func make_character(pos, faction, type):
  var character = char_scenes[type].instance()
  add_child(character)
  character.set_start_position(pos)
  character.set_faction(faction)
  return character

const shop_pool = {
  'Character': 5,
  'Thrower': 5,
  'Mystic': 10,
}

func build_shop_pool():
  for char_type in shop_pool:
    for _i in range(shop_pool[char_type]):
      var pool_character = make_character(Vector2(0, 0), 'friendly', char_type)
      pool_character.visible = false
      character_pool.append(pool_character)

func load_next_level():
  for c in battlefield_characters:
    if c.faction == 'enemy':
      c.visible = false
      remove_child(c)
    elif c.faction == 'friendly':
      c.reset()
  cur_level += 1
  if cur_level >= 2:
    cur_level = 2
  for enemy_position in levels[cur_level]:
    var enemy = make_character(enemy_position, 'enemy', 'Character')
    battlefield_characters.append(enemy)

func buy_character(c):
  gold -= c.cost
  $ShopGUI.update()
  c.in_shop = false
  battlefield_characters.append(c)
  party_characters.append(c)

func setup_debug_scenerio():
  var friendly = make_character(Vector2(300, 300), 'friendly', 'Character')
  var enemy = make_character(Vector2(700, 300), 'enemy', 'Character')
  battlefield_characters = [friendly, enemy]

# Called when the node enters the scene tree for the first time.
func _ready():
  build_shop_pool()
  # setup_debug_scenerio()
  var friendly = make_character(Vector2(400, 180), 'friendly', 'Character')
  battlefield_characters.append(friendly)
  load_next_level()
  $ShopGUI.open_shop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
  if not paused:
    for character in battlefield_characters:
      character.act(self)

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
    for c in battlefield_characters:
      if c.faction == 'enemy' and not c.dead:
        battle_won = false
      if c.faction == 'friendly' and not c.dead:
        battle_lost = false
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
