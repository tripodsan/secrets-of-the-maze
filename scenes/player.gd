class_name Player
extends Area2D

var _engine_type := Global.EngineType.Tank

@export var thrust := 3.0
@export var v_damp := 0.1
@export var rot_speed := 0.1

var velocity := 0
var a_velo := 0.0
var a_damp := 0.2
var a_dir := 0.0
var dir := Vector2.ZERO
var pos := Vector2.ZERO

func _ready() -> void:
  pos = position
  Global.engine_type_selected.connect(set_engine)

func _apply_forces(delta:float) ->void:
  a_dir = wrapf(a_dir + a_velo, 0, TAU)
  a_velo = lerpf(a_velo, 0, a_damp)
  dir = Vector2.from_angle(a_dir)

  pos += dir * velocity
  velocity = lerpf(velocity, 0, v_damp)

func _physics_process(delta: float) -> void:
  var input:Vector2 = Input.get_vector("left", "right", "fwd", "backwd")

  if _engine_type == Global.EngineType.Tank:
    if input.x != 0:
      a_velo = input.x * rot_speed
    if input.y != 0:
      velocity -= input.y * thrust
  else:
    var v = input.length()
    if v != 0:
      velocity += v * thrust
      dir = input
      a_dir = dir.angle()

  _apply_forces(delta)

  rotation = a_dir
  position = pos


func set_engine(type:Global.EngineType):
  _engine_type = type
