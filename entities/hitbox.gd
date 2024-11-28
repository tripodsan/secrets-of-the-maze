extends Area2D

func _on_body_entered(body: Node2D) -> void:
  prints('hitbox body entered:', body)
  var blast:Blast = body as Blast
  if blast:
    var dmg:float = blast.get_damage(get_parent().global_position)
    get_parent().apply_damage(dmg)
    return
  var f:Fighter = body as Fighter
  if f:
    get_parent().apply_damage(50)
    f.hit()
