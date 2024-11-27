extends Control

@onready var level_suffix: LevelSuffixLabel = %level_suffix
@onready var level_name: Label = %level_name
@onready var level_timer:LevelTimer = %level_timer

func _ready() -> void:
  GameController.layer_activated.connect(_on_layer_activated)
  GameController.level_loaded.connect(_on_level_loaded)

func _on_layer_activated(layer:ChromaLayer)->void:
  level_suffix.set_color_scheme(layer.type)

func _on_level_loaded(l:Level)->void:
  level_name.text = l._game_data.get_title()
  l.state_changed.connect(_on_level_state_changed.bind(l))
  level_timer.set_time(0)

var current_level:Level
var prev_time:int = -1

func _on_level_state_changed(l:Level)->void:
  if l.state == Level.State.STARTED:
    current_level = l
  else:
    current_level = null

func _process(_delta: float) -> void:
  if current_level:
    level_timer.set_time(current_level.get_run_time())
