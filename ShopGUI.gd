extends Control

func update():
  $BackgroundPanel/VBoxContainer/HBoxContainer/GoldAmountLabel.text = str(get_parent().gold)

# Called when the node enters the scene tree for the first time.
func _ready():
  update()

const row_height = 150
var chars_for_sale = []

static func delete_children(node):
  for c in node.get_children():
    node.remove_child(c)
    c.queue_free()

func open_shop():
  visible = true
  refresh_shop()
  get_parent().paused = true
  get_parent().shop_open = true
  get_parent().get_node("StartRoundButton").visible = true

func close_shop():
  visible = false
  clear_shop()
  get_parent().paused = false
  get_parent().shop_open = false
  get_parent().get_node("StartRoundButton").visible = false

func clear_shop():
  var chars_for_sale_node = $BackgroundPanel/VBoxContainer/CharsForSale
  delete_children(chars_for_sale_node)
  for c in chars_for_sale:
    get_parent().character_pool.append(c)
    if c.in_shop:
      c.visible = false
  chars_for_sale = []

func refresh_shop():
  print('refreshing')
  var chars_for_sale_node = $BackgroundPanel/VBoxContainer/CharsForSale
  clear_shop()
  var char_pool = get_parent().character_pool
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
    cur_char.visible = true
    cur_char.in_shop = true
    # this doesn't work for some reason
    # cur_char.position = row.rect_position + Vector2(100, 50)
    cur_char.position = cur_row_position + Vector2(100, 50)
    cur_row_position += Vector2(0, row_height)
    chars_for_sale.append(cur_char)

func _on_RerollButton_pressed():
  if get_parent().gold >= get_parent().reroll_cost:
    get_parent().gold -= get_parent().reroll_cost
    update()
    refresh_shop()
  else:
    print('not enough money!')
