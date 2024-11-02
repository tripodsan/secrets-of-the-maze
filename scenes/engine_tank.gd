extends Node

@onready var player: Area2D = $'..'

@export var thrust := 3.0
@export var v_damp := 0.1
@export var rot_speed := 0.1

var velocity := 0
var a_velo := 0.0
var a_damp := 0.2
var a_dir := 0.0
var dir := Vector2.ZERO

func _physics_process(delta: float) -> void:
  var input:Vector2 = Input.get_vector("left", "right", "backwd", "fwd")

  if input.x != 0:
    a_velo = input.x * rot_speed
  a_dir = wrapf(a_dir + a_velo, 0, TAU)
  a_velo = lerpf(a_velo, 0, a_damp)
  player.rotation = a_dir
  dir = Vector2.from_angle(a_dir)

  if input.y != 0:
    velocity += input.y * thrust
  player.position += dir * velocity
  velocity = lerpf(velocity, 0, v_damp)
