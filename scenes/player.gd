class_name Player
extends CharacterBody2D

var _engine_type := Global.EngineType.Tank

@export var thrust := 80.0
@export var v_damp := 0.1
@export var rot_speed := 5.0

var a_velo := 0.0
var v_velo := 0.0
var a_damp := 0.2
var a_dir := 0.0
var dir := Vector2.ZERO

var trail:PackedVector2Array = PackedVector2Array()
var trail_pos:int = 0

func _ready() -> void:
  Global.engine_type_selected.connect(set_engine)
  trail.resize(8)

func _physics_process(delta: float) -> void:
  var input:Vector2 = Input.get_vector("left", "right", "fwd", "backwd")
#
  if _engine_type == Global.EngineType.Tank:
    if input.x != 0:
      a_velo = input.x * rot_speed * delta
    if input.y != 0:
      v_velo -= input.y * thrust
  else:
    var v = input.length()
    if v != 0:
      v_velo += v * thrust
      dir = input
      a_dir = dir.angle()

  a_dir = wrapf(a_dir + a_velo, 0, TAU)
  a_velo = lerpf(a_velo, 0, a_damp)
  dir = Vector2.from_angle(a_dir)

  rotation = a_dir
  velocity = transform.x * v_velo
  v_velo = lerpf(v_velo, 0.0, v_damp)
  var col:KinematicCollision2D = move_and_collide(velocity * delta)
  if col:
    v_velo = 0.0
  RenderingServer.global_shader_parameter_set("player_pos", trail[trail_pos])
  trail[trail_pos] = global_position
  trail_pos = (trail_pos + 1) % len(trail)


func set_engine(type:Global.EngineType):
  _engine_type = type
