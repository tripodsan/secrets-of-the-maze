extends Node2D

@onready var main: GPUParticles2D = $main
@onready var smoke: GPUParticles2D = $smoke
@onready var flash: Polygon2D = $flash

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  visible = true
  main.one_shot = true
  main.emitting = false
  smoke.one_shot = true
  smoke.emitting = false
  main.finished.connect(_on_particles_finished)

func fire():
  flash.visible = true
  main.emitting = true
  smoke.emitting = true
  await get_tree().create_timer(0.05).timeout
  flash.visible = false

func _on_particles_finished():
  main.emitting = false
  smoke.emitting = false
