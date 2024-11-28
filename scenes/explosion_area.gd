extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  connect("body_entered", _on_body_entered, CONNECT_ONE_SHOT)

func _on_body_entered(body):
  %MineMesh.visible = false
  $explosion.explode()
  if body is Player:
    body.hit(Global.HitType.Mine)
  await get_tree().create_timer(1.0).timeout
  get_parent().queue_free()
