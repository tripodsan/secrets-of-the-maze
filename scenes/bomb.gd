extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
var time_alive := 0.0
var velocity := Vector2(0.0, 0.0)

func initialize(pos: Vector2, vel: Vector2):
  velocity = vel
  global_position = pos

func _process(delta: float) -> void:
  global_position += velocity
  velocity *= 0.97
  time_alive += delta
  if time_alive > 3.0:
    Global.supernova.emit()
    queue_free()
  rotate(.08)
