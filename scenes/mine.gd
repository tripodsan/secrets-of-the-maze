extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.

var _time := 0.0
func _process(delta: float) -> void:
  
  _time += delta
  $MeshInstance2D.material.set_shader_parameter("time", _time)
