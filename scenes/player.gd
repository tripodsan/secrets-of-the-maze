class_name Player
extends CharacterBody2D

## front surface area (m²)
@export_range(0.0, 10.0, 0.1, "or_greater") var a_front := 30.0

## side surface area (m²)
@export_range(0.0, 10.0, 0.1, "or_greater") var a_side := 100.0

## back surface area (m²)
@export_range(0.0, 10.0, 0.1, "or_greater") var a_back := 500.0

## "fluid density" (kg/m³)
@export_range(0.0, 10.0, 0.0001, "or_greater") var density := 0.01

## mass (kg)
@export_range(0.0, 10.0, 0.1, "or_greater") var mass := 50.0

## forward thrust force (N)
@export_range(0.0, 10.0, 0.1, "or_greater") var f_fwd := 300000.0

## backward thrust force (N)
@export_range(0.0, 10.0, 0.1, "or_greater") var f_back := 100000.0

## side thrust force (N)
@export_range(0.0, 10.0, 0.1, "or_greater") var f_side := 200000.0

## rotation speed
@export_range(0.0, 10.0, 0.1, "or_greater") var rot_speed := 6.0

## rotation angular damp
@export_range(0.0, 10.0, 0.1, "or_greater") var rot_damp := 0.2

## rotation velocity
var rot_velo := 0.0

## rotation direction
var rot_angle := 0.0
var rot_dir := Vector2.RIGHT

var trail:PackedVector4Array = PackedVector4Array()
var trail_pos:int = 0

# todo: use states
var is_destroyed:bool = false

func _ready() -> void:
  trail.resize(6)
  Global.set_player(self)

func _input(event: InputEvent) -> void:
  if Input.is_action_just_pressed('laser'):
    $ship/LaserCast.set_is_casting(true)
  if Input.is_action_just_released('laser'):
    $ship/LaserCast.set_is_casting(false)
  if Input.is_action_just_pressed('missile'):
    %ProjectileManager.shoot_projectile(position+rot_dir*50.0, rot_dir, 750.0, 0.0, 2.0)

func _physics_process(delta: float) -> void:
  if is_destroyed: return
  var input:Vector2 = Input.get_vector("left", "right", "fwd", "backwd")
#
  var f:Vector2  # thrust
  if input.x != 0:
    rot_velo = input.x * rot_speed * delta
  rot_angle = fposmod(rot_angle + rot_velo, TAU)
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

  var coll:KinematicCollision2D = move_and_collide(velocity * delta)
  if coll:
    if coll.get_collider() is TileMapLayer:
      var map:TileMapLayer = coll.get_collider()
      var pos:Vector2i = map.get_coords_for_body_rid(coll.get_collider_rid())
      var data:TileData = map.get_cell_tile_data(pos)
      if data.get_custom_data("type") == &"spike":
        hit(Global.HitType.Spike)
        return
    var wall := coll.get_normal()
    var a:float = wall.dot(rot_dir)
    if abs(a) > 0.8:
      var t:Vector2 = coll.get_remainder().bounce(wall)
      position += t * 1.1
      velocity = velocity.bounce(wall)
      rot_angle = t.angle()
    else:
      # slide
      rot_dir = rot_dir.slide(wall).normalized()
      rot_angle = rot_dir.angle()
      velocity = velocity.slide(wall)
      position += coll.get_remainder().slide(wall)

  RenderingServer.global_shader_parameter_set("player_pos_and_vel", trail[trail_pos])
  trail[trail_pos] = Vector4(global_position.x, global_position.y, velocity.x, velocity.y)
  trail_pos = (trail_pos + 1) % len(trail)
  #prints('a:', A, 'd:', density, 'dpv:', f_dpv, 'f:', f, 'f_dir:', f_dir, 'a_tot:', a_tot, 'v:', velocity, 'p:', position)

func hit(type:Global.HitType)->void:
  is_destroyed = true
  $ship.visible = false
  var explosion = load
  $Explosion.fire()
  RenderingServer.global_shader_parameter_set("player_pos_and_vel", Vector4.ZERO)
  await get_tree().create_timer(1.5).timeout
  Global.player_destroyed.emit(type)

func reset(pos:Vector2)->void:
  is_destroyed = false
  $ship.visible = true
  trail.fill(Vector4.ZERO)
  position = pos
  rotation = 0
  velocity = Vector2.ZERO
  rot_angle = 0
  rot_dir = Vector2.RIGHT
