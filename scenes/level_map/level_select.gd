extends Control

@onready var level_map: LevelMap = $level_map
@onready var level_title: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/level_title
@onready var level_suffix: LevelSuffixLabel = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/level_suffix
@onready var level_info: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/level_info

func _ready() -> void:
  level_map.level_selected.connect(_on_level_selected)
  level_map.level_accepted.connect(_on_level_accepted)
  _on_level_selected(level_map.selected_level)

func _on_level_selected(l:LevelMapNode)->void:
  level_title.text = l.title
  level_suffix.color_scheme = l.gd_layer.idx

  var hsec = l.gd_layer.best_time / 10
  var sec = hsec / 100
  var time = '%02d:%02d.%02d' % [sec / 60, sec % 60, hsec % 100]

  level_info.text = '\n'.join([
    '0 / 5',
    time,
    '1 / 1'
  ]);

func _on_level_accepted(l:LevelMapNode)->void:
  GameController.start_level(l.gd_layer)

func _on_launch_pressed() -> void:
  GameController.start_level(level_map.selected_level.gd_layer)
