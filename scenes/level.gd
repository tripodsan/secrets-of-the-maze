class_name Level
extends Node2D

@onready var blue: ChromaLayer = $blue
@onready var red: ChromaLayer = $red
@onready var green: ChromaLayer = $green

@export var nr:int = -1

var _layers:Array[ChromaLayer] = [];

var _layer:Global.Layer = Global.Layer.BLUE

var _prev_layer:Global.Layer = Global.Layer.NONE

var _game_data:GDLevel

var _start_portal:Portal
var _start_layer:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  if nr < 0:
    prints('leftover scene level. discarding...')
    get_parent().remove_child(self)
    self.queue_free()
    return
  _layers = [blue, red, green]
  _game_data = GameData.get_level(nr)
  for l in _layers:
    l.set_active(false)
    l.set_game_data(_game_data.get_layers()[l.idx])
  Global.layer_selected.connect(_on_layer_selected)
  Global.player_destroyed.connect(_on_player_destroyed)

func _on_player_destroyed(_by)->void:
  restart()

func _on_layer_selected(layer:Global.Layer):
  _layers[_layer].set_active(false)
  _prev_layer = _layer
  _layer = layer
  _layers[_layer].set_active(true)

func chroma_shift()->void:
  var pos = Global.player.global_position
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
  Global.player.reset(_start_portal.global_transform)
  get_viewport().get_camera_2d().reset_smoothing()
  _on_layer_selected(_start_layer)

func restart()->void:
  Global.player.reset(_start_portal.global_transform)
  _on_layer_selected(_start_layer)
