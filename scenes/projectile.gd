extends Node2D

var speed := 400.0
var direction := Vector2.UP
var lifespan := 2.0
var time_alive = 0.0
var type := 0

func stop():
  visible = false
  
func _physics_process(delta: float) -> void:
  if visible:
    position += direction * speed * delta
    time_alive += delta
    if time_alive > lifespan:
      stop()
      
