class_name Level
extends Node2D

@onready var blue: ChromaLayer = $blue
@onready var red: ChromaLayer = $red
@onready var green: ChromaLayer = $green

@export var nr:int = -1

enum State {
  LOADED,
  READY,
  STARTING,
  STARTED,
  STOPPING,
  STOPPED,
  DESTROYED
}

var state:State = State.LOADED

signal state_changed()

var _layers:Array[ChromaLayer] = [];

var _layer:Global.Layer = Global.Layer.BLUE

var _prev_layer:Global.Layer = Global.Layer.NONE

var _game_data:GDLevel

var _start_portal:Portal
var _start_layer:int

var _level_start_time:int
var _level_stop_time:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  if nr < 0:
    prints('leftover scene level. discarding...')
    self.queue_free()
    return
  _layers = [blue, red, green]
  _game_data = GameData.get_level(nr)
  for l in _layers:
    l.set_active(false)
    l.set_game_data(_game_data.get_layers()[l.idx])
  Global.layer_selected.connect(_on_layer_selected)
  GameController.get_player_deferred(_on_player_loaded)
  GameController.portal_reached.connect(_on_portal_reached)
  GameController.set_level(self)
  set_state(State.READY)

func set_state(s:State)->void:
  state = s
  prints('layer state:', State.keys()[state])
  state_changed.emit()

func _on_player_loaded(p:Player)->void:
  p.state_changed.connect(_on_player_state_changed.bind(p))

func _on_player_state_changed(p:Player)->void:
  if p.state == Player.State.DESTROYED:
    restart()

func _on_layer_selected(layer:Global.Layer):
  if layer != _prev_layer:
    _layers[_layer].set_active(false)
    _prev_layer = _layer
    _layer = layer
    _layers[_layer].set_active(true)

func _on_portal_reached(p:Portal)->void:
  print('portal reached')
  _level_stop_time = Time.get_ticks_msec()
  #Global.level_stopped.emit(self)
  await get_tree().create_timer(2.0).timeout
  print('portal reset')
  restart()

func chroma_shift()->void:
  var pos = GameController.player.global_position
  var candidate = -1
  for i in range(0, len(_layers)):
    if i != _layer && _layers[i].can_chroma_shift(pos):
      if candidate < 0:
        candidate = i
      elif candidate == _prev_layer:
        candidate = i
  if candidate >= 0:
    Global.layer_selected.emit(candidate)

func _process(_delta: float) -> void:
  if Input.is_action_just_pressed('switch'):
    chroma_shift()

func set_game_data(level:GDLevel)->void:
  _game_data = level

func start(layer:Global.Layer, portal:int = 0)->void:
  _start_layer = layer
  _layer = layer
  _start_portal = _layers[layer].get_portal(portal)
  assert(_start_portal)
  _start_portal.enabled = false
  restart()
  get_viewport().get_camera_2d().reset_smoothing()

func restart()->void:
  GameController.player.activate(_start_portal.global_transform)
  _on_layer_selected(_start_layer)
  #Global.level_started.emit(self)
  set_state(State.STARTED)
  _level_start_time = Time.get_ticks_msec()
  _level_stop_time = 0

## returns the level time in milliseconds
func get_run_time()->int:
  var t = _level_stop_time
  if t == 0: t = Time.get_ticks_msec()
  return t - _level_start_time
