class_name Player
extends CharacterBody2D

## front surface area (m²)
@export_range(0.0, 10.0, 0.1, "or_greater") var a_front := 30.0

## side surface area (m²)
@export_range(0.0, 10.0, 0.1, "or_greater") var a_side := 100.0

## back surface area (m²)
@export_range(0.0, 10.0, 0.1, "or_greater") var a_back := 500.0

## "fluid density" (kg/m³)
@export_range(0.0, 10.0, 0.0001, "or_greater") var density := 0.02

## mass (kg)
@export_range(0.0, 10.0, 0.1, "or_greater") var mass := 50.0

## forward thrust force (N)
@export_range(0.0, 10.0, 0.1, "or_greater") var f_fwd := 500000.0

## backward thrust force (N)
@export_range(0.0, 10.0, 0.1, "or_greater") var f_back := 100000.0

## side thrust force (N)
@export_range(0.0, 10.0, 0.1, "or_greater") var f_side := 200000.0

## rotation speed
@export_range(0.0, 10.0, 0.1, "or_greater") var rot_speed := 4.0

## rotation angular damp
@export_range(0.0, 10.0, 0.1, "or_greater") var rot_damp := 0.2

## rotation velocity
var rot_velo := 0.0

## rotation direction
var rot_angle := 0.0
var rot_dir := Vector2.RIGHT

var trail:PackedVector2Array = PackedVector2Array()
var trail_pos:int = 0

func _ready() -> void:
  trail.resize(6)
  Global.set_player(self)

func _input(event: InputEvent) -> void:
  if Input.is_action_just_pressed('laser'):
    $ship/LaserCast.set_is_casting(true)
  if Input.is_action_just_released('laser'):
    $ship/LaserCast.set_is_casting(false)
  if Input.is_action_just_pressed('missile'):
    %ProjectileManager.shoot_projectile(trail[trail_pos], rot_dir, 500.0, 0.0, 5.0)
    
func _physics_process(delta: float) -> void:
  var input:Vector2 = Input.get_vector("left", "right", "fwd", "backwd")
#
  var f:Vector2  # thrust
  if input.x != 0:
    rot_velo = input.x * rot_speed * delta
  rot_angle += rot_velo
  rot_dir = Vector2.from_angle(rot_angle)
  rot_velo = lerpf(rot_velo, 0, rot_damp)
  if input.y < 0:
    f = rot_dir * f_fwd
  elif input.y > 0:
    f = -rot_dir * f_back

  # add side trusters
  if f_side > 0:
    var strafe:Vector2 = Input.get_vector("strafe_left", "strafe_right", "fwd", "backwd")
    strafe.y = 0
    f += strafe.rotated(rot_angle + PI/2) * f_side

  # calculate exposed surface area (depends on velocity direction and orientation)
  var r := 0.0
  if velocity.length_squared()>0:
    r = velocity.normalized().dot(rot_dir)
  var A:float;
  if r < 0:
    A = lerpf(a_side, a_back, -r)
  else:
    A = lerpf(a_side, a_front, r)

  # drag force per velocity
  var f_dpv := 0.5 * velocity.length() * density * A

  # drag force with direction
  var f_dir := velocity * f_dpv

  # acceleration
  var a_tot := (f - f_dir) / mass

  velocity += a_tot * delta
  rotation = rot_dir.angle()

  var col:KinematicCollision2D = move_and_collide(velocity * delta)
  if col:
    velocity = Vector2.ZERO
  RenderingServer.global_shader_parameter_set("player_pos_and_vel", Vector4(trail[trail_pos].x, trail[trail_pos].y, velocity.x, velocity.y))
  trail[trail_pos] = global_position
  trail_pos = (trail_pos + 1) % len(trail)
  #prints('a:', A, 'd:', density, 'dpv:', f_dpv, 'f:', f, 'f_dir:', f_dir, 'a_tot:', a_tot, 'v:', velocity, 'p:', position)
