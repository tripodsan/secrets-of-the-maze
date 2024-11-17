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

var trail:PackedVector4Array = PackedVector4Array()
var trail_pos:int = 0

# todo: use states
var is_destroyed:bool = false

func _ready() -> void:
  trail.resize(6)
  Global.set_player(self)
  Global.supernova.connect(%SuperNova.trigger_supernova)

func _input(_event: InputEvent) -> void:
  if Input.is_action_just_pressed('laser'):
    $ship/LaserCast.set_is_casting(true)
  if Input.is_action_just_released('laser'):
    $ship/LaserCast.set_is_casting(false)
  if Input.is_action_just_pressed('missile'):
    %ProjectileManager.shoot_projectile(position+transform.x*50.0, transform.x, 750.0, 0, 2.0)
  if Input.is_action_just_pressed('bomb'):
    var bomb = load("res://scenes/bomb.tscn").instantiate()
    bomb.initialize(global_position+transform.x*10.0, -transform.x * 3.0)
    get_parent().add_child(bomb)

func _physics_process(delta: float) -> void:
  if is_destroyed: return
  var input:Vector2 = Input.get_vector("left", "right", "fwd", "backwd")
#
  var f:Vector2  # thrust
  if input.x != 0:
    rot_velo = input.x * rot_speed * delta
  var rot_angle = fposmod(rotation + rot_velo, TAU)
  var rot_dir = Vector2.from_angle(rot_angle)
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

  var coll:KinematicCollision2D = move_and_collide(velocity * delta)
  if coll:
    var body:Object = coll.get_collider()
    var type:StringName = Global.get_tile_type(body, coll.get_collider_rid())
    if type == &"spike":
      hit(Global.HitType.Spike)
      return
    elif body is Node2D and body.is_in_group(&"spike"):
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
      rot_velo = 0
      velocity = velocity.slide(wall)
      position += coll.get_remainder().slide(wall)

  rotation = rot_angle

  RenderingServer.global_shader_parameter_set("player_pos_and_vel", trail[trail_pos])
  trail[trail_pos] = Vector4(global_position.x, global_position.y, velocity.x, velocity.y)
  trail_pos = (trail_pos + 1) % len(trail)
  #prints('a:', A, 'd:', density, 'dpv:', f_dpv, 'f:', f, 'f_dir:', f_dir, 'a_tot:', a_tot, 'v:', velocity, 'p:', position)

func hit(type:Global.HitType)->void:
  is_destroyed = true
  $ship.visible = false
  $Explosion.fire()
  RenderingServer.global_shader_parameter_set("player_pos_and_vel", Vector4.ZERO)
  await get_tree().create_timer(1.5).timeout
  Global.player_destroyed.emit(type)

func reset(xf:Transform2D)->void:
  is_destroyed = false
  $ship.visible = true
  trail.fill(Vector4.ZERO)
  global_transform = xf
  velocity = Vector2.ZERO
  rot_velo = 0
