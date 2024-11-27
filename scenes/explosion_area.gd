extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  connect("body_entered", _on_body_entered)

func reset()->void:
  $MineMesh.visible = true
  connect("body_entered", _on_body_entered)

func _on_body_entered(body):
  disconnect("body_entered", _on_body_entered)
  $MineMesh.visible = false
  $explosion.explode()
  if body is Player:
    body.hit(Global.HitType.Mine)
  await get_tree().create_timer(1.0).timeout
  get_parent().disable()
