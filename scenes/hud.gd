extends Control

@onready var level_suffix: LevelSuffixLabel = $MarginContainer/VBoxContainer/level_suffix
@onready var level_name: Label = $MarginContainer/VBoxContainer/level_name
@onready var level_time_secs: Label = $MarginContainer/VBoxContainer/level_time_secs
@onready var level_time_ts: Label = $MarginContainer/VBoxContainer/level_time_ts

func _ready() -> void:
  Global.layer_activated.connect(_on_layer_activated)
  Global.level_loaded.connect(_on_level_loaded)
  Global.level_started.connect(_on_level_started)
  Global.level_stopped.connect(_on_level_stopped)

func _on_layer_activated(l:Global.Layer)->void:
  level_suffix.set_color_scheme(l)

func _on_level_loaded(l:Level)->void:
  level_name.text = l._game_data.get_title()

var current_level:Level
var prev_time:int = -1

func _on_level_started(l:Level)->void:
  current_level = l

func _on_level_stopped(l:Level)->void:
  current_level = null

func _process(delta: float) -> void:
  if current_level:
    var t:int = current_level.get_run_time() / 100
    if t != prev_time:
      prev_time = t
      var s = t / 10
      level_time_secs.text = '%d:%02d' % [s / 60, s % 60]
      level_time_ts.text = '.%d' % [t % 10]
