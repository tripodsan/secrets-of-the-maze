extends Line2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
var animation := 0.0
func _process(delta: float) -> void:
  animation -= delta*1.5
  material.set_shader_parameter("animation", animation)
