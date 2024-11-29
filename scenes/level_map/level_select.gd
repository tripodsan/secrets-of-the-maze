extends Control

@onready var level_map: LevelMap = $level_map
@onready var level_title: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/level_title
@onready var level_suffix: LevelSuffixLabel = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/level_suffix

@onready var lab_secrets: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/lab_secrets
@onready var lab_chroma: CrystalInfo = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/lab_chroma

@onready var lab_self_time: CrystalInfo = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/lab_self_time
@onready var lab_alt_0_time: CrystalInfo = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/lab_alt0_time
@onready var lab_alt_1_time: CrystalInfo = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/lab_alt1_time

@onready var times:Array[CrystalInfo] = [lab_self_time, lab_alt_0_time, lab_alt_1_time]

func _ready() -> void:
  level_map.level_selected.connect(_on_level_selected)
  level_map.level_accepted.connect(_on_level_accepted)
  _on_level_selected(level_map.selected_level)

func _on_level_selected(l:LevelMapNode)->void:
  var type:Global.Layer = l.gd_layer.type
  level_title.text = l.title
  level_suffix.color_scheme = type

  var alt0 = (type + 1) % 3
  var alt1 = (type + 2) % 3
  for i in range(3):
    var time = Global.format_time(l.gd_layer.best_times[i])
    if i == type:
      lab_self_time.get_node('time').text = time
      lab_self_time.set_crystals(Global.LAYER_MASK[type])
    elif i == alt0:
      lab_alt_0_time.get_node('time').text = time
      lab_alt_0_time.set_crystals(Global.LAYER_MASK[alt0])
    else:
      lab_alt_1_time.get_node('time').text = time
      lab_alt_1_time.set_crystals(Global.LAYER_MASK[alt1])

  lab_secrets.text = '%d / %d' % [l.gd_layer.num_secrets, l.gd_layer.max_secrets]
  lab_chroma.set_crystals(l.gd_layer.crystals)

func _on_level_accepted(l:LevelMapNode)->void:
  GameController.start_level(l.gd_layer)

func _on_launch_pressed() -> void:
  GameController.start_level(level_map.selected_level.gd_layer)

func _on_btn_back_title_pressed() -> void:
  GameController.show_title_screen()
