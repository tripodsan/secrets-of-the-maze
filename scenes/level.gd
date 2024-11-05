extends Node2D

@onready var blue: ChromaLayer = $blue
@onready var red: ChromaLayer = $red
@onready var green: ChromaLayer = $green

var _layers:Array[ChromaLayer] = [];

var _layer:ChromaLayer = null

var _prev_layer:ChromaLayer = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  _layers = [blue, red, green]
  for l in _layers: l.set_active(false)
  Global.layer_selected.connect(_on_layer_selected)
  _on_layer_selected(_layer)

func _on_layer_selected(layer:Global.Layer):
  _layers[_layer].set_active(false)
  _prev_layer = _layer
  _layer = layer
  _layers[_layer].set_active(true)

func chroma_shift()->void:
  var p:Player = %player
  var candidates:Array[Global.Layer] = []
  for l:ChromaLayer in _layers:
    if l.can_chroma_shift(p.global_position):
      candidates.append()

  Global.layer_selected.emit((_layer + 1)%3)

func _process(delta: float) -> void:
  if Input.is_action_just_pressed('switch'):
    chroma_shift()
