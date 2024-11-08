extends Node2D

@onready var blue: ChromaLayer = $blue
@onready var red: ChromaLayer = $red
@onready var green: ChromaLayer = $green

var _layers:Array[ChromaLayer] = [];

var _layer:Global.Layer = Global.Layer.Blue

var _prev_layer:Global.Layer = -1

var _start_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  _layers = [blue, red, green]
  for l in _layers: l.set_active(false)
  _start_position = get_start_position()
  assert(_start_position != Vector2.ZERO)
  Global.layer_selected.connect(_on_layer_selected)
  _on_layer_selected(_layer)

  # todo: move level logic to game controller
  await get_tree().process_frame
  start()
  Global.player_destroyed.connect(_on_player_destroyed)

func _on_player_destroyed(by)->void:
  start()
  pass

func _on_layer_selected(layer:Global.Layer):
  _layers[_layer].set_active(false)
  _prev_layer = _layer
  _layer = layer
  _layers[_layer].set_active(true)

func chroma_shift()->void:
  var p:Player = %player
  var candidate = -1
  for i in range(0, len(_layers)):
    if i != _layer && _layers[i].can_chroma_shift(p.global_position):
      if candidate < 0:
        candidate = i
      elif candidate == _prev_layer:
        candidate = i
  if candidate >= 0:
    Global.layer_selected.emit(candidate)

func _process(delta: float) -> void:
  if Input.is_action_just_pressed('switch'):
    chroma_shift()

func get_start_position()->Vector2:
  for l in _layers:
    var v = l.get_start_position()
    if v != Vector2.ZERO:
      return v
  return Vector2.ZERO

func start()->void:
  Global.player.reset(_start_position)
  _on_layer_selected(Global.Layer.Blue)
