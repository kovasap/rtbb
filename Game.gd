extends Node2D

var gold = 10

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

var paused = true
var characters = []

onready var char_scene = load("res://Character.tscn")
func make_character(pos, faction):
	var character = char_scene.instance()
	add_child(character)
	character.position = pos
	character.faction = faction
	if faction == 'enemy':
		character.color = Color(1, 0, 0, 1)
	elif faction == 'friendly':
		character.color = Color(0, 1, 0, 1)
	return character

func load_next_level():
	for c in characters:
		if c.faction == 'enemy':
			remove_child(c)
	cur_level += 1
	for enemy_position in levels[cur_level]:
		var enemy = make_character(enemy_position, 'enemy')
		characters.append(enemy)
		enemy.rate_of_fire = 500

func open_shop():
	$ShopGUI.visible = true
	$StartRoundButton.visible = true
	$ShopGUI.refresh_shop()

func buy_character(c):
	gold -= c.cost
	$ShopGUI.update()
	c.in_shop = false
	characters.append(c)

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(30):
		var pool_character = make_character(Vector2(0, 0), 'friendly')
		pool_character.visible = false
		character_pool.append(pool_character)
	var friendly = make_character(Vector2(400, 180), 'friendly')
	characters.append(friendly)
	load_next_level()
	open_shop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not paused:
		for character in characters:
			character.act(self)

	var battle_won = true
	var battle_lost = true

	for c in characters:
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
		open_shop()

func _on_Button_pressed():
	$ShopGUI.visible = false
	$StartRoundButton.visible = false
	paused = false
