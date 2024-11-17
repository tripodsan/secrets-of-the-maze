extends Control

@onready var level_suffix: LevelSuffixLabel = $MarginContainer/VBoxContainer/level_suffix
@onready var level_name: Label = $MarginContainer/VBoxContainer/level_name

func _ready() -> void:
  Global.layer_activated.connect(_on_layer_activated)
  Global.level_loaded.connect(_on_level_loaded)

func _on_layer_activated(l:Global.Layer)->void:
  level_suffix.set_color_scheme(l)

func _on_level_loaded(l:Level)->void:
  level_name.text = l._game_data.get_title()
