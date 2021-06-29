extends Control

onready var Synergies = preload("res://characters/Synergies.gd").new()

const row_height = 150
var chars_for_sale = []
onready var game = get_parent()

func update():
  $ShopBackground/VBoxContainer/HBoxContainer/GoldAmountLabel.text = \
      str(game.gold)

# Keyed by synergy name for easier updating.
var synergies_panel_labels = {}

func update_synergies(synergy_levels):
  for synergy in synergy_levels:
    var tiers = Synergies.synergies[synergy]['num_chars_required']
    synergies_panel_labels[synergy].text = \
        '%s %s (%s)' % [synergy, synergy_levels[synergy],
                        PoolStringArray(tiers).join(' ')]

func setup_synergies_panel():
  for synergy in Synergies.synergies:
    var row = HBoxContainer.new()
    row.rect_min_size = Vector2(0, row_height)
    var synergy_label = RichTextLabel.new()
    row.add_child(synergy_label)
    var tiers = Synergies.synergies[synergy]['num_chars_required']
    synergy_label.size_flags_horizontal = SIZE_EXPAND_FILL
    synergy_label.text = \
        '%s 0 (%s)' % [synergy, PoolStringArray(tiers).join(' ')]
    $TeamBackground/VBoxContainer/Synergies.add_child(row)
    synergies_panel_labels[synergy] = synergy_label

func update_party_size_description():
  $TeamBackground/VBoxContainer/PartySizeDescription.text = \
      'Party Size: %s/%s' % [game.characters['party'].size(), game.max_party_size]

# Called when the node enters the scene tree for the first time.
func _ready():
  setup_synergies_panel()
  update()

func _process(_delta):
  update_party_size_description()

static func delete_children(node):
  for c in node.get_children():
    node.remove_child(c)
    c.queue_free()

func open_shop():
  $ShopBackground.visible = true
  refresh_shop()
  game.paused = true
  game.shop_open = true
  game.get_node("StartRoundButton").visible = true

func close_shop():
  $ShopBackground.visible = false
  clear_shop()
  game.paused = false
  game.shop_open = false
  game.get_node("StartRoundButton").visible = false

func clear_shop():
  var chars_for_sale_node = $ShopBackground/VBoxContainer/CharsForSale
  delete_children(chars_for_sale_node)
  for c in chars_for_sale:
    game.characters['pool'].append(c)
    if c.in_shop:
      c.visible = false
  chars_for_sale = []

func refresh_shop():
  var chars_for_sale_node = $ShopBackground/VBoxContainer/CharsForSale
  clear_shop()
  var char_pool = game.characters['pool']
  char_pool.shuffle()
  var cur_row_position = Vector2(0, 50)
  for i in 4:
    var cur_char = char_pool.pop_back()
    var row = VBoxContainer.new()
    var cost_label = RichTextLabel.new()
    cost_label.text = 'Cost: %sg' % cur_char.cost
    cost_label.rect_min_size = Vector2(50, row_height)
    row.add_child(cost_label)
    row.rect_min_size = Vector2(0, row_height)
    chars_for_sale_node.add_child(row)
    row.connect("gui_input", cur_char, "_on_Character_input_event_shop")
    cost_label.connect("gui_input", cur_char, "_on_Character_input_event_shop")
    cur_char.show_and_enable()
    cur_char.in_shop = true
    # this doesn't work for some reason
    # cur_char.position = row.rect_position + Vector2(100, 50)
    cur_char.position = cur_row_position + Vector2(100, 50)
    cur_row_position += Vector2(0, row_height)
    chars_for_sale.append(cur_char)

func _on_RerollButton_pressed():
  if game.gold >= game.reroll_cost:
    game.gold -= game.reroll_cost
    update()
    refresh_shop()
  else:
    print('not enough money!')


func _on_BenchBackground_mouse_entered():
  game.hovering_over_bench = true

func _on_BenchBackground_mouse_exited():
  game.hovering_over_bench = false

func _on_ShopBackground_mouse_entered():
  game.hovering_over_ui = true

func _on_ShopBackground_mouse_exited():
  game.hovering_over_ui = false

func _on_TeamBackground_mouse_entered():
  game.hovering_over_ui = true

func _on_TeamBackground_mouse_exited():
  game.hovering_over_ui = false
