extends Control

@onready var level_map: LevelMapV2 = %level_map

@onready var level_title: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/level_title
@onready var level_suffix: LevelSuffixLabel = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/level_suffix

@onready var lab_secrets: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/lab_secrets
@onready var lab_chroma: CrystalInfo = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/lab_chroma

@onready var lab_self_time: CrystalInfo = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/lab_self_time
@onready var lab_alt_0_time: CrystalInfo = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/lab_alt0_time
@onready var lab_alt_1_time: CrystalInfo = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/lab_alt1_time

@onready var times:Array[CrystalInfo] = [lab_self_time, lab_alt_0_time, lab_alt_1_time]

@onready var cheat_spoiler: Cheatcode = $cheat_spoiler
@onready var cheat_crystals: Cheatcode = $cheat_crystals
@onready var cheat_wormhole: Cheatcode = $cheat_wormhole

func _ready() -> void:
  level_map.level_selected.connect(_on_level_selected)
  level_map.level_accepted.connect(_on_level_accepted)
  cheat_spoiler.unlocked.connect(_on_spoiler_unlocked)
  cheat_crystals.unlocked.connect(_on_crystals_unlocked)
  cheat_wormhole.unlocked.connect(_on_wormhole_unlocked)
  _on_level_selected(level_map.selected_level)

func _on_spoiler_unlocked()->void:
  SoundController.play_sfx(&"secret")
  GameData.unlock_all(true)

func _on_crystals_unlocked()->void:
  SoundController.play_sfx(&"secret")
  level_map.selected_level.get_level().unlock_all(true)

func _on_wormhole_unlocked()->void:
  SoundController.play_sfx(&"secret")
  GameData.unlock_all(false)

func _on_level_selected(layer:GDLayer)->void:
  var type:Global.Layer = layer.type
  level_title.text = layer.get_level().get_title()
  level_suffix.color_scheme = type

  var alt0 = (type + 1) % 3
  var alt1 = (type + 2) % 3
  for i in range(3):
    var time = Global.format_time(layer.best_times[i])
    if i == type:
      lab_self_time.get_node('time').text = time
      lab_self_time.set_crystals(Global.LAYER_MASK[type])
    elif i == alt0:
      lab_alt_0_time.get_node('time').text = time
      lab_alt_0_time.set_crystals(Global.LAYER_MASK[alt0])
    else:
      lab_alt_1_time.get_node('time').text = time
      lab_alt_1_time.set_crystals(Global.LAYER_MASK[alt1])

  lab_secrets.text = '%d / %d' % [layer.num_secrets, layer.max_secrets]
  lab_chroma.set_crystals(layer.crystals)

func _on_level_accepted(layer:GDLayer)->void:
  GameController.start_level(layer)

func _on_launch_pressed() -> void:
  GameController.start_level(level_map.selected_level)

func _on_btn_back_title_pressed() -> void:
  GameController.show_title_screen()
