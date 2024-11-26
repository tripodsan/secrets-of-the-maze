extends RigidBody2D

@onready var sprite: Sprite2D = $sprite

var time_alive := 0.0

func initialize(pos: Vector2, vel: Vector2):
  global_position = pos
  linear_velocity = vel

func _process(delta: float) -> void:
  time_alive += delta
  if time_alive > 3.0:
    Global.supernova.emit()
    queue_free()
  sprite.rotate(.2)
