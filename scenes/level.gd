extends Node2D

@onready var blue: Node2D = $blue
@onready var red: Node2D = $red

var _layer := Global.Layer.Blue
var _chromatic_distortion_material
var _chromatic_distortion := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  Global.layer_selected.connect(_on_layer_selected)
  _on_layer_selected(_layer)
  _chromatic_distortion_material = get_node("/root/main/CanvasLayer/ChromaticDistortion").material

func _on_layer_selected(layer:Global.Layer):
  _chromatic_distortion = 3.0
  blue.visible = layer == Global.Layer.Blue
  blue.process_mode = Node.PROCESS_MODE_INHERIT if layer == Global.Layer.Blue else PROCESS_MODE_DISABLED
  red.visible = layer == Global.Layer.Red
  red.process_mode = Node.PROCESS_MODE_INHERIT if layer == Global.Layer.Red else PROCESS_MODE_DISABLED
  _layer = layer

func _process(delta: float) -> void:
  if Input.is_action_just_pressed('switch'):
    Global.layer_selected.emit((_layer + 1)%2)
  if _chromatic_distortion > 0.01:
    _chromatic_distortion *= 0.9
    _chromatic_distortion_material.set_shader_parameter("amount", _chromatic_distortion);
