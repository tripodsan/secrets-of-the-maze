extends ColorRect

var _chromatic_distortion := 0.0

func _ready() -> void:
  visible = false
  size = get_viewport_rect().size
  Global.layer_selected.connect(_on_layer_selected)

func _on_layer_selected(layer:Global.Layer):
  var tween := get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
  tween.tween_method(_on_chroma_update, 2.5, 0.0, 1.0)

func _on_chroma_update(distortion:float)->void:
  if distortion == 0:
    visible = false
  else:
    visible = true
    material.set_shader_parameter("amount", distortion);