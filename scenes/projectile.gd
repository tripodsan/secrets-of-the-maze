extends Node2D

var speed := 400.0
var direction := Vector2.UP
var lifespan := 2.0
var time_alive = 0.0
var type := 0

func start():
  $CharacterBody2D/GPUParticles2D.restart()
  visible = true
  
func stop():
  visible = false
  
func _physics_process(delta: float) -> void:
  if visible:
    global_position += direction * speed * delta
    time_alive += delta
    var scale_f = min(0.6, time_alive)
    $CharacterBody2D/Sprite2D.scale = Vector2(scale_f, scale_f*0.5)
    $CharacterBody2D/Sprite2D.rotate(time_alive*0.2)
    if time_alive >= lifespan:
      stop()
      
