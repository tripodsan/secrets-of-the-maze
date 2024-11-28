extends Node2D

@onready var explosion: Explosion = $explosion
@onready var visual: MeshInstance2D = $visual

var target = null
var layer:Global.Layer = Global.Layer.NONE
var velocity := Vector2(0, 0)
const max_speed := 900.0
var speed := 10.0

func set_target(t:Node2D)->void:
  target = t
  visual.material.set_shader_parameter("activity", 1.1)

func _process(delta: float) -> void:
  rotation += delta*3.0

  if target:
    global_position += velocity * delta * GameData.get_settings().maze_scale
    if speed < max_speed:
      speed *= 1.09
    var v_to_target = (target.global_position - global_position).normalized()
    velocity = velocity.lerp(v_to_target * speed, 0.5)

func _on_explosion_area_body_entered(body: Node2D) -> void:
  visual.visible = false
  explosion.explode()
  if body is Player:
    body.hit(Global.HitType.Mine)
  await get_tree().create_timer(1.0).timeout
  queue_free()
