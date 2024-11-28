extends RigidBody2D

var lifespan := 2.0
var time_alive = 0.0

@onready var trail: GPUParticles2D = $trail
@onready var sprite: Sprite2D = $sprite
@onready var hitbox: HitBox = $hitbox
@onready var collision: CollisionShape2D = $collision

func _ready() -> void:
  GameController.maze_scale_changed.connect(_on_maze_scale_changed)
  _on_maze_scale_changed()

func _on_maze_scale_changed()->void:
  # adjust the scaling based on level scale, because a ridgid body can't be scaled
  var s = Vector2.ONE * GameData.get_settings().maze_scale
  trail.scale = s
  sprite.scale = s * 0.3
  collision.scale = s

func start(pos:Vector2, vel:Vector2):
  global_position = pos
  linear_velocity = vel
  hitbox.set_disabled(false)
  collision.set_deferred('disabled', false)
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

func get_damage()->float:
  return 100

func apply_damage(amount:float, source:Node2D)->void:
  prints('projectile %s hit by %s' % [self, source])
  hit()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
  for i in range(get_contact_count()):
    var obj = state.get_contact_collider_object(i)
    var tile_type:StringName = Global.get_tile_type(obj, state.get_contact_collider(i))
    if tile_type == &"spike":
      hit.call_deferred()
      return
    #if obj.has_method('apply_damage'):
      #obj.apply_damage(50)
      #hit.call_deferred()
      #return

func _physics_process(delta: float) -> void:
  if !visible: return
  time_alive += delta
  if time_alive >= lifespan + trail.lifetime:
    visible = false
    return
  if time_alive >= lifespan:
    hit.call_deferred()
    return
  #var scale_f = min(0.6, time_alive)
  #sprite.scale = Vector2(scale_f, scale_f*0.5)
  sprite.rotate(min(1.0, time_alive*0.2))

func hit():
  sprite.visible = false
  trail.emitting = false
  hitbox.set_disabled(true)
  set_deferred('freeze', true)
  #await get_tree().process_frame
  collision.set_deferred('disabled', true)

func reset():
  hit()
  stop()
