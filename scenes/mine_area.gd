extends Area2D

var velocity := Vector2(0, 0)
var target = null
const max_speed := 900.0
var speed := 10.0

func reset()->void:
  target = null
  speed = 10
  velocity = Vector2.ZERO
  %MineMesh.material.set_shader_parameter("activity", 0.35)

func _ready() -> void:
  connect("body_entered", _on_entered)

func _on_entered(body):
  if body is Player:
    target = body
    %MineMesh.material.set_shader_parameter("activity", 1.1)

func _process(delta: float) -> void:
  if target:
    get_parent().global_position += velocity * delta * GameData.get_settings().maze_scale
    if speed < max_speed:
      speed *= 1.09
    var v_to_target = (target.global_position - global_position).normalized()
    velocity = velocity.lerp(v_to_target * speed, 0.5)
