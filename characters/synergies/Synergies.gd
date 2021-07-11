class_name Synergies

# TODO DELETE THIS OLD FILE!!

const synergies = {
  'mercenary': {
    'num_chars_required': [2],
    'characters': ['Soldier', 'Thrower'],
  }
}


# Halved ability cooldowns for all mercenaries.
static func apply_mercenary_synergy(party_characters, level):
  if level == 0:
    return
  for c in party_characters:
    if c.get_class_name() in synergies['mercenary']['characters']:
      if level == 1:
        print('Applying level 1 merc synergy to %s' % c.get_class_name())
        for a in c.abilities:
          a.cooldown = 0.5 * a.cooldown
      elif level == 2:
        for a in c.abilities:
          a.cooldown = 0.5 * a.cooldown


static func get_synergy_levels(party_characters):
  var unique_character_types = {}
  for c in party_characters:
    unique_character_types[c.get_class_name()] = null

  var synergy_levels = {}
  for synergy in synergies:
    var num_chars = 0
    for c in synergies[synergy]['characters']:
      if c in unique_character_types:
        num_chars += 1
    synergy_levels[synergy] = 0
    for num_chars_required in synergies[synergy]['num_chars_required']:
      if num_chars <= num_chars_required:
        synergy_levels[synergy] += 1
      else:
        break
  return synergy_levels


static func apply_synergies(party_characters):
  var synergy_levels = get_synergy_levels(party_characters)
  print(synergy_levels)
  apply_mercenary_synergy(party_characters, synergy_levels['mercenary'])

