class_name Player
extends RigidBody2D

## front surface area (m²)
@export_range(0.0, 10.0, 0.1, "or_greater") var a_front := 30.0

## side surface area (m²)
@export_range(0.0, 10.0, 0.1, "or_greater") var a_side := 50.0

## back surface area (m²)
@export_range(0.0, 10.0, 0.1, "or_greater") var a_back := 300.0

## "fluid density" (kg/m³)
@export_range(0.0, 10.0, 0.0001, "or_greater") var density := 0.02

## mass (kg)
#@export_range(0.0, 10.0, 0.1, "or_greater") var mass := 50.0

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

func _input(_event: InputEvent) -> void:
  if Input.is_action_just_pressed('laser'):
    $ship/LaserCast.set_is_casting(true)
  if Input.is_action_just_released('laser'):
    $ship/LaserCast.set_is_casting(false)
  if Input.is_action_just_pressed('missile'):
    %ProjectileManager.shoot_projectile(position+rot_dir*50.0, rot_dir, 750.0, 0.0, 2.0)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
  if is_destroyed: return

  for i in range(get_contact_count()):
    var col = state.get_contact_collider_object(i)
    if col is TileMapLayer:
      var map:TileMapLayer = col
      var pos:Vector2i = map.get_coords_for_body_rid(state.get_contact_collider(i))
      var data:TileData = map.get_cell_tile_data(pos)
      if !data: continue
      #if data.get_custom_data("type") == &"spike":
        #hit(Global.HitType.Spike)
        #return
      var wall := state.get_contact_local_normal(i)
      var a:float = wall.dot(transform.x)
      if abs(a) > 0.8:
        rot_dir = state.transform.x.bounce(wall).normalized()
        rot_angle = rot_dir.angle()
        rot_velo = 0
        state.transform.x = rot_dir
        #var t:Vector2 = state.get_velocity_at_local_position(state.get_contact_local_position(i))
        #prints(t)
        #state.linear_velocity = t.bounce(wall)
        #var t:Vector2 = coll.get_remainder().bounce(wall)
        #position += t * 1.1
        #velocity = velocity.bounce(wall)
        #rot_angle = t.angle()
        pass
      else:
        # slide
        prints('slide')
        rot_dir = state.transform.x.slide(wall).normalized()
        rot_angle = rot_dir.angle()
        rot_velo = 0
        state.transform.x = rot_dir
        state.linear_velocity = linear_velocity.slide(wall)
        #position += coll.get_remainder().slide(wall)
      break

  var input:Vector2 = Input.get_vector("left", "right", "fwd", "backwd")
#
  var f:Vector2  # thrust
  #state.apply_torque(input.x * 5000000)
  if input.x != 0:
    rot_velo = input.x * rot_speed * state.step
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

  state.apply_central_force(f)
  state.transform.x = rot_dir
  # calculate exposed surface area (depends on velocity direction and orientation)
  var r := 0.0
  if state.linear_velocity.length_squared()>0:
    r = state.linear_velocity.normalized().dot(state.transform.x)
  var A:float;
  if r < 0:
    A = lerpf(a_side, a_back, -r)
  else:
    A = lerpf(a_side, a_front, r)


  ## drag force per velocity
  linear_damp = density * A
  #var f_dpv := 0.5 * velocity.length() * density * A
#
  ## drag force with direction
  #var f_dir := velocity * f_dpv
#
  ## acceleration
  #var a_tot := (f - f_dir) / mass
#
  #velocity += a_tot * delta
  #rotation = rot_dir.angle()

  #var coll:KinematicCollision2D = move_and_collide(velocity * delta)
  #if coll:
    #if coll.get_collider() is TileMapLayer:
      #var map:TileMapLayer = coll.get_collider()
      #var pos:Vector2i = map.get_coords_for_body_rid(coll.get_collider_rid())
      #var data:TileData = map.get_cell_tile_data(pos)
      #if data.get_custom_data("type") == &"spike":
        #hit(Global.HitType.Spike)
        #return
    #var wall := coll.get_normal()
    #var a:float = wall.dot(rot_dir)
    #if abs(a) > 0.8:
      #var t:Vector2 = coll.get_remainder().bounce(wall)
      #position += t * 1.1
      #velocity = velocity.bounce(wall)
      #rot_angle = t.angle()
    #else:
      ## slide
      #rot_dir = rot_dir.slide(wall).normalized()
      #rot_angle = rot_dir.angle()
      #velocity = velocity.slide(wall)
      #position += coll.get_remainder().slide(wall)
#
  #RenderingServer.global_shader_parameter_set("player_pos_and_vel", trail[trail_pos])
  #trail[trail_pos] = Vector4(global_position.x, global_position.y, velocity.x, velocity.y)
  #trail_pos = (trail_pos + 1) % len(trail)
  ##prints('a:', A, 'd:', density, 'dpv:', f_dpv, 'f:', f, 'f_dir:', f_dir, 'a_tot:', a_tot, 'v:', velocity, 'p:', position)

func hit(type:Global.HitType)->void:
  is_destroyed = true
  $ship.visible = false
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
  linear_velocity = Vector2.ZERO
  angular_velocity = 0;
  rot_angle = 0
  rot_dir = Vector2.RIGHT
