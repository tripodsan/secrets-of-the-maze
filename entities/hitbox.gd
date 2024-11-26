extends Area2D

func _on_body_entered(body: Node2D) -> void:
  prints('body entered:', body)
  get_parent().apply_damage()
