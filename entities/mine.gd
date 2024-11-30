extends Node2D

@onready var explosion: Explosion = $explosion
@onready var visual: MeshInstance2D = $visual
@onready var collision: CollisionShape2D = $ExplosionArea/collision

var target = null
var layer:Global.Layer = Global.Layer.NONE
var velocity := Vector2(0, 0)
const max_speed := 900.0
var speed := 10.0

signal destroyed()

func set_target(t:Node2D)->void:
  target = t
  visual.material.set_shader_parameter("activity", 1.1)

func _ready()->void:
  collision.disabled = !ChromaLayer.is_in_active_layer(self)

func _process(delta: float) -> void:
  rotation += delta*3.0

  if target:
    global_position += velocity * delta * GameData.get_settings().maze_scale
    if speed < max_speed:
      speed *= 1.09
    var v_to_target = (target.global_position - global_position).normalized()
    velocity = velocity.lerp(v_to_target * speed, 0.5)

func _on_explosion_area_body_entered(body: Node2D) -> void:
  prints('mine explodes..', self)
  visual.visible = false
  explosion.explode()
  GameController.create_blast(global_position, 200, 500, true, true)
  destroyed.emit()
  await get_tree().create_timer(1.0).timeout
  prints('mine frees..', self)
  get_parent().remove_child(self)
  queue_free()
