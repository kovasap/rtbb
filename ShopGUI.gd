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

func refresh_shop():
	print('refreshing')
	var chars_for_sale_node = $BackgroundPanel/VBoxContainer/CharsForSale
	delete_children(chars_for_sale_node)
	var char_pool = get_parent().character_pool
	char_pool.shuffle()
	var cur_row_position = Vector2(0, 50)
	for i in 4:
		var row = VBoxContainer.new()
		var cost_label = RichTextLabel.new()
		cost_label.text = 'Cost: %sg' % char_pool[i].cost
		cost_label.rect_min_size = Vector2(50, row_height)
		row.add_child(cost_label)
		row.rect_min_size = Vector2(0, row_height)
		chars_for_sale_node.add_child(row)
		row.connect("gui_input", char_pool[i], "_on_Character_input_event_shop")
		cost_label.connect("gui_input", char_pool[i], "_on_Character_input_event_shop")
		char_pool[i].visible = true
		# this doesn't work for some reason
		# char_pool[i].position = row.rect_position + Vector2(100, 50)
		char_pool[i].position = cur_row_position + Vector2(100, 50)
		cur_row_position += Vector2(0, row_height)
		chars_for_sale.append(char_pool[i])
