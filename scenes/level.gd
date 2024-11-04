extends Node2D

@onready var blue: Node2D = $blue
@onready var red: Node2D = $red
@onready var green: Node2D = $green

var _layer := Global.Layer.Blue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  Global.layer_selected.connect(_on_layer_selected)
  _on_layer_selected(_layer)

func _on_layer_selected(layer:Global.Layer):
  get_viewport().set_canvas_cull_mask_bit(1, layer == Global.Layer.Blue)
  get_viewport().set_canvas_cull_mask_bit(2, layer == Global.Layer.Red)
  get_viewport().set_canvas_cull_mask_bit(3, layer == Global.Layer.Green)
  %phasemap.set_canvas_cull_mask_bit(1, layer != Global.Layer.Blue)
  %phasemap.set_canvas_cull_mask_bit(2, layer != Global.Layer.Red)
  %phasemap.set_canvas_cull_mask_bit(3, layer != Global.Layer.Green)
  blue.process_mode = Node.PROCESS_MODE_INHERIT if layer == Global.Layer.Blue else PROCESS_MODE_DISABLED
  red.process_mode = Node.PROCESS_MODE_INHERIT if layer == Global.Layer.Red else PROCESS_MODE_DISABLED
  green.process_mode = Node.PROCESS_MODE_INHERIT if layer == Global.Layer.Green else PROCESS_MODE_DISABLED

  _layer = layer

func _process(delta: float) -> void:
  if Input.is_action_just_pressed('switch'):
    Global.layer_selected.emit((_layer + 1)%3)
