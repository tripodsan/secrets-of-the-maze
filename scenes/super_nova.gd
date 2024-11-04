extends ColorRect

var _chromatic_distortion := 0.0

func _ready() -> void:
  visible = false 

func _input(event) -> void:
  if Input.is_key_pressed(KEY_B):
    _on_supernova()
    
func _on_supernova():
  var tween := get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
  tween.tween_method(_on_supernova_update, 0.0, 1.0, 2.0)

func _on_supernova_update(distortion:float)->void:
  if distortion == 1.0  :
    visible = false
  else:
    visible = true
    material.set_shader_parameter("amount", distortion);
