extends CharacterBody2D

var lifespan := 2.0
var time_alive = 0.0
var type := 0

@onready var trail: GPUParticles2D = $trail
@onready var sprite: Sprite2D = $sprite

func start():
  process_mode = PROCESS_MODE_INHERIT
  trail.restart()
  time_alive = 0
  visible = true

func stop():
  process_mode = PROCESS_MODE_DISABLED
  visible = false

func _physics_process(delta: float) -> void:
  if !visible: return
  time_alive += delta
  if time_alive >= lifespan:
    stop()
    return

  var col:KinematicCollision2D = move_and_collide(velocity * delta)
  if col:
    stop()
  else:
    var scale_f = min(0.6, time_alive)
    sprite.scale = Vector2(scale_f, scale_f*0.5)
    sprite.rotate(time_alive*0.2)
