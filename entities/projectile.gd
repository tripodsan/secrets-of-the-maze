extends RigidBody2D

var lifespan := 2.0
var time_alive = 0.0
var type := 0

@onready var trail: GPUParticles2D = $trail
@onready var sprite: Sprite2D = $sprite

func _ready() -> void:
  body_shape_entered.connect(_on_body_shape_entered)

func start(pos:Vector2, vel:Vector2):
  global_position = pos
  linear_velocity = vel
  process_mode = PROCESS_MODE_INHERIT
  trail.restart()
  time_alive = 0
  freeze = false
  sleeping = false
  sprite.visible = true
  visible = true

func stop():
  process_mode = PROCESS_MODE_DISABLED
  visible = false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
  for i in range(get_contact_count()):
    var obj = state.get_contact_collider_object(i)
    var tile_type:StringName = Global.get_tile_type(obj, state.get_contact_collider(i))
    if tile_type == &"spike":
      hit.call_deferred()
      return
    if obj.has_method('apply_damage'):
      obj.apply_damage(10)
      hit.call_deferred()
      return

func _physics_process(delta: float) -> void:
  if !visible: return
  time_alive += delta
  if time_alive >= lifespan:
    hit.call_deferred()
    return

  #var scale_f = min(0.6, time_alive)
  #sprite.scale = Vector2(scale_f, scale_f*0.5)
  sprite.rotate(min(1.0, time_alive*0.2))

func hit():
  sprite.visible = false
  trail.emitting = false
  freeze = true

@warning_ignore('unused_parameter')
func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int):
  pass
