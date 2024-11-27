class_name Fighter
extends CharacterBody2D

@onready var explosion: Explosion = $explosion
@onready var shape: Polygon2D = $shape
@onready var collision: CollisionShape2D = $collision
@onready var nav_agent: NavigationAgent2D = $nav_agent

const MAX_SPEED = 500.0

var speed = 20

var speed_delta:float = 0

func _ready()->void:
  modulate.a = 0
  nav_agent.velocity_computed.connect(_on_velocity_computed)

func hit():
  explosion.explode()
  shape.visible = false
  collision.set_disabled.call_deferred(true)
  await get_tree().create_timer(1.0).timeout
  queue_free()

func apply_damage(_amount:int)->void:
  hit()

func _physics_process(delta: float) -> void:
  if modulate.a < 1.0:
    modulate.a += 0.1

  if GameController.player == null:
    queue_free()
    return

  nav_agent.target_position = GameController.player.global_position
  var ppos:Vector2 = nav_agent.get_next_path_position()

  var a:float = get_angle_to(ppos)
  rotation = lerp_angle(rotation, rotation + a, 0.5)
  if speed < MAX_SPEED:
    speed *= 1.1

  speed_delta = speed * delta
  var new_velocity:Vector2 = transform.x * speed * GameData.get_settings().maze_scale
  if nav_agent.avoidance_enabled:
    nav_agent.set_velocity(new_velocity)
  else:
    _on_velocity_computed(new_velocity)

func _on_velocity_computed(v:Vector2)->void:
  velocity = v# * speed_delta
  #global_position = global_position.move_toward(global_position + v, speed_delta)
  move_and_slide()
  for i in get_slide_collision_count():
    var col:KinematicCollision2D = get_slide_collision(i)
    var body:Object = col.get_collider()
    var type:StringName = Global.get_tile_type(body, col.get_collider_rid())
    if type == &"spike":
      hit()
