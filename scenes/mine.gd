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
  $ExplosionArea/collision.disabled = false
  $DetectionArea/collision.disabled = false

func disable()->void:
  visible = false
  $DetectionArea.target = null
  $ExplosionArea/collision.disabled = true
  $DetectionArea/collision.disabled = true
