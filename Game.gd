extends Node2D

const reroll_cost = 2
var gold = 10
var shop_open = false

var cur_level = 0
# Each level describes enemy positions for that level.
# TODO give this better structure.
const levels = [
  [Vector2(700, 200)],
  [Vector2(700, 200), Vector2(700, 300), Vector2(700, 100)],
  [Vector2(700, 200), Vector2(700, 300), Vector2(700, 100),
   Vector2(850, 200), Vector2(850, 300), Vector2(850, 100)],
]

var character_pool = []

var party_characters = []

var paused = true
var battlefield_characters = []

onready var char_scenes = {
  'Character': load("res://characters/Character.tscn"),
  'Thrower': load("res://characters/Thrower.tscn"),
}
func make_character(pos, faction, type):
  var character = char_scenes[type].instance()
  add_child(character)
  character.position = pos
  character.start_position = pos
  character.faction = faction
  if faction == 'enemy':
    character.color = Color(1, 0, 0, 1)
  elif faction == 'friendly':
    character.color = Color(0, 1, 0, 1)
  return character

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
    enemy.attack_cooldown = 500

func buy_character(c):
  gold -= c.cost
  $ShopGUI.update()
  c.in_shop = false
  battlefield_characters.append(c)
  party_characters.append(c)

# Called when the node enters the scene tree for the first time.
func _ready():
  for _i in range(30):
    var pool_character = make_character(Vector2(0, 0), 'friendly', 'Thrower')
    pool_character.visible = false
    character_pool.append(pool_character)
  var friendly = make_character(Vector2(400, 180), 'friendly', 'Character')
  battlefield_characters.append(friendly)
  load_next_level()
  $ShopGUI.open_shop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
  if not paused:
    for character in battlefield_characters:
      character.act(self)

  var battle_won = true
  var battle_lost = true

  for c in battlefield_characters:
    if c.faction == 'enemy' and not c.dead:
      battle_won = false
    if c.faction == 'friendly' and not c.dead:
      battle_lost = false
  if battle_won or battle_lost:
    if battle_won:
      $ResultAnnouncement.text = 'Battle %s Won!' % cur_level
    if battle_lost:
      $ResultAnnouncement.text = 'Battle %s Lost!' % cur_level
    $ResultAnnouncement.visible = true
    if not shop_open:
      $ShopGUI.open_shop()
      load_next_level()

func _on_Button_pressed():
  $ShopGUI.close_shop()
