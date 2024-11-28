extends Control

@onready var level_suffix: LevelSuffixLabel = %level_suffix
@onready var level_name: Label = %level_name
@onready var level_timer:LevelTimer = %level_timer

@onready var bar_health: HealthBar = %bar_health
@onready var bar_shield: HealthBar = %bar_shield

func _ready() -> void:
  GameController.layer_activated.connect(_on_layer_activated)
  GameController.level_loaded.connect(_on_level_loaded)
  GameController.player_loaded.connect(_on_player_loaded)

func _on_layer_activated(layer:ChromaLayer)->void:
  level_suffix.set_color_scheme(layer.type)

func _on_level_loaded(l:Level)->void:
  level_name.text = l._game_data.get_title()
  l.state_changed.connect(_on_level_state_changed.bind(l))
  level_timer.set_time(0)

func _on_player_loaded(p:Player)->void:
  p.health_changed.connect(_on_player_health_changed)

var current_level:Level
var prev_time:int = -1

func _on_level_state_changed(l:Level)->void:
  if l.state == Level.State.STARTED:
    current_level = l
  else:
    current_level = null

func _on_player_health_changed(h:float)->void:
  bar_health.percent = h

func _process(_delta: float) -> void:
  if current_level:
    level_timer.set_time(current_level.get_run_time())
