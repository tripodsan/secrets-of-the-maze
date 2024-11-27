extends Node2D

var _start_pos:Vector2

func _ready() -> void:
  _start_pos = position

func _process(delta: float) -> void:
  rotation += delta*3.0

func reset()->void:
  position = _start_pos
  visible = true
  $DetectionArea.reset()
  $ExplosionArea.reset()
  $ExplosionArea/collision.set_disabled.call_deferred(false)
  $DetectionArea/collision.set_disabled.call_deferred(false)

func disable()->void:
  visible = false
  $DetectionArea.target = null
  $ExplosionArea/collision.set_disabled.call_deferred(true)
  $DetectionArea/collision.set_disabled.call_deferred(true)
