extends Control

@onready var logo: TextureRect = %logo
@onready var timer: Timer = $Timer

@onready var projectile: RigidBody2D = $particles/Projectile
@onready var laser_cast: Laser = $particles/LaserCast
@onready var explosion: Explosion = $particles/explosion
@onready var ship_explosion: Node2D = $particles/ship_explosion

func _ready() -> void:
  SoundController.play_intro()
  Global.fade(logo, 0.0, 1.0, 2.0)
  preload_particles()

func _on_timer_timeout()->void:
  GameController.show_title_screen()

func _input(event: InputEvent) -> void:
  if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
    timer.stop()
    _on_timer_timeout()

func preload_particles()->void:
  projectile.start(projectile.global_position, Vector2.ZERO)
  laser_cast.set_active(true)
  explosion.explode()
  ship_explosion.fire()
