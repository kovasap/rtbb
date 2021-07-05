extends VBoxContainer

var synergy

func _ready():
  pass


func update_image(faction):
  $Symbol.set_texture(synergy.images[synergy.get_num_chars(faction)])
