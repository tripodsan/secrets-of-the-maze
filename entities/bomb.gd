extends RigidBody2D

@onready var sprite: Sprite2D = $sprite

var time_alive := 0.0

func initialize(pos: Vector2, vel: Vector2):
  global_position = pos
  linear_velocity = vel
  SoundController.play_sfx(&"bomb_tick")

func _process(delta: float) -> void:
  time_alive += delta
  if time_alive > 1.5:
    GameController.create_blast(global_position, 200, 1000, false, true)
    Global.supernova.emit()
    SoundController.play_sfx(&"supernova")
    queue_free()
  sprite.rotate(.2)
