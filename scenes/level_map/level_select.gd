extends Control

@onready var level_map: LevelMap = $level_map
@onready var level_title: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/level_title
@onready var level_suffix: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/level_suffix

func _ready() -> void:
  level_map.level_selected.connect(_on_level_selected)

func _on_level_selected(l:LevelMapNode)->void:
  level_title.text = l.title
  level_suffix.text = l.suffix
