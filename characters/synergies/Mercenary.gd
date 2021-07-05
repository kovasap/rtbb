extends Synergy


# https://github.com/godotengine/godot/issues/21789
func get_class(): return 'Mercenary'


func _ready():
  images = [
    preload('res://characters/synergies/mercenary_0.png'),
    preload('res://characters/synergies/mercenary_1.png'),
    preload('res://characters/synergies/mercenary_2.png'),
    preload('res://characters/synergies/mercenary_3.png'),
    preload('res://characters/synergies/mercenary_4.png'),
  ]
  num_chars_required = [2, 4]
  ._ready()


func update_character(c):
  var level = get_level(c.faction)
  if level == 1:
    print('Applying level 1 merc synergy to %s' % c.get_class())
    for a in c.abilities:
      a.cooldown = 0.5 * a.cooldown
  elif level == 2:
    for a in c.abilities:
      a.cooldown = 0.5 * a.cooldown
