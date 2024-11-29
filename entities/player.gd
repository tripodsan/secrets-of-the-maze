class_name Player
extends CharacterBody2D

@onready var ship: Polygon2D = $ship
@onready var laser: Laser = $ship/laser

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

## rotation speed
@export_range(0.0, 10.0, 0.1, "or_greater") var rot_speed_laser := 2.0

## rotation angular damp
@export_range(0.0, 10.0, 0.1, "or_greater") var rot_damp := 0.2

## rotation velocity
var rot_velo := 0.0

var trail:PackedVector4Array = PackedVector4Array()
var trail_pos:int = 0

signal state_changed()

signal health_changed(health:float)

enum State {
  ## inital state right after initialized
  LOADED,

  ## player _ready is called
  READY,

  ## player is getting ready in the level
  ACTIVATING,

  ## player is active in the level
  ACTIVE,

  ## player is deactivating, eg when reaching the portal
  DEACTIVATING,

  ## player is deactivated
  DEACTIVATED,

  ## player is getting destroyed
  DESTROYING,

  ## player is destroyed
  DESTROYED,
}

var state:State = State.LOADED

var portal:Portal = null
var portal_time:float = 0
var portal_speed:float = 0.1

var health:float = 100

var start_health:float = 100

func _ready() -> void:
  trail.resize(6)
  GameController.set_player(self)
  Global.supernova.connect(%SuperNova.trigger_supernova)
  set_state(State.READY)

func set_state(s:State)->void:
  state = s
  prints('player state:', State.keys()[state])
  if state != State.ACTIVE:
    laser.set_active(false)
    collision_layer = 0
  else:
    collision_layer = 1
  state_changed.emit()

func _input(_event: InputEvent) -> void:
  if state == State.ACTIVATING and Input.is_anything_pressed():
    set_state(State.ACTIVE)

  if state != State.ACTIVE: return

  if Input.is_action_just_pressed('laser'):
    laser.set_active(true)
  if Input.is_action_just_released('laser'):
    laser.set_active(false)
  if Input.is_action_just_pressed('missile'):
    %ProjectileManager.shoot_projectile(global_transform)
  if Input.is_action_just_pressed('bomb'):
    %ProjectileManager.launch_bomb(global_transform)

func update_trail()->void:
  RenderingServer.global_shader_parameter_set("player_pos_and_vel", trail[trail_pos])
  trail[trail_pos] = Vector4(global_position.x, global_position.y, velocity.x, velocity.y)
  trail_pos = (trail_pos + 1) % len(trail)

func _physics_process(delta: float) -> void:
  if state == State.DEACTIVATING and portal:
    var d := portal.get_spiral_pos(portal_time)
    global_position = portal.global_position + d
    rotation = d.angle() + PI/2 * portal.ph_scale
    portal_time += delta * portal_speed
    portal_speed += delta * 0.2
    update_trail()
    ship.scale = lerp(Vector2.ONE, Vector2(0.2, 0.2), min(portal_time, 1.0))
    if portal_time > 0.7:
      ship.visible = false
      ship.scale = Vector2.ONE
      set_state(State.DEACTIVATED)
    return

  if state != State.ACTIVE: return

  var input:Vector2 = Input.get_vector("left", "right", "fwd", "backwd")
#
  var f:Vector2  # thrust
  if input.x != 0 && !Input.is_action_pressed('strafe_left') && !Input.is_action_pressed('strafe_right'):
    var rs = rot_speed_laser if laser.is_active else rot_speed
    rot_velo = input.x * rs * delta
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

  var coll:KinematicCollision2D = move_and_collide(velocity * delta * GameData.get_settings().maze_scale)
  if coll:
    var body:Object = coll.get_collider()
    var type:StringName = Global.get_tile_type(body, coll.get_collider_rid())
    if type == &"spike":
      apply_damage(100, body)
      return
    elif body is Node2D and body.is_in_group(&"spike"):
      apply_damage(100, body)
      return

    var wall := coll.get_normal()
    var a:float = wall.dot(rot_dir)
    if abs(a) > 0.8:
      var t:Vector2 = coll.get_remainder().bounce(wall)
      position += t * 1.1
      velocity = velocity.bounce(wall)
      rot_angle = t.angle()
      apply_damage(2, body)
    else:
      # slide
      rot_dir = rot_dir.slide(wall).normalized()
      rot_angle = rot_dir.angle()
      rot_velo = 0
      velocity = velocity.slide(wall)
      position += coll.get_remainder().slide(wall)

  rotation = rot_angle
  update_trail()
  #prints('a:', A, 'd:', density, 'dpv:', f_dpv, 'f:', f, 'f_dir:', f_dir, 'a_tot:', a_tot, 'v:', velocity, 'p:', position)

func apply_damage(amount:float, source:Node2D)->void:
  if state != State.ACTIVE: return
  health = max(0, health - amount)
  prints('%s applied damamage %f -> %f to %s' % [source, amount, health, self])
  health_changed.emit(health)
  if health == 0:
    $ship.visible = false
    $Explosion.fire()
    trail.fill(Vector4.ZERO)
    RenderingServer.global_shader_parameter_set("player_pos_and_vel", Vector4.ZERO)
    set_state(State.DESTROYING)
    await get_tree().create_timer(1.5).timeout
    set_state(State.DESTROYED)

func activate(xf:Transform2D)->void:
  prints('activate', xf)
  global_transform = xf
  portal = null
  visible = true
  $ship.visible = true
  trail.fill(Vector4.ZERO)
  velocity = Vector2.ZERO
  rot_velo = 0
  health = start_health
  health_changed.emit(health)
  set_state(State.ACTIVATING)


func portal_enter(p:Portal)->void:
  if !portal and state == State.ACTIVE:
    prints('->', p)
    portal = p
    portal.ph_scale = 1.0 if get_angle_to(portal.global_position) > 0 else -1.0
    portal.init_spiral(global_position)
    portal_time = 0
    portal_speed = velocity.length() * 0.0002
    velocity = Vector2.ZERO
    set_state(State.DEACTIVATING)
    GameController.portal_reached.emit(portal)

func pickup(body:Node2D)->void:
  if body is ChromaCrystal:
    GameController.on_chroma_crystal_pickup.call_deferred(body.type)
