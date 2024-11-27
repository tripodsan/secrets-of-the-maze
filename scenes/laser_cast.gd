class_name Laser
extends RayCast2D

var is_active := false

var damange:int = 10

const DISTANCE = 1300

@onready var laser_line: Line2D = $LaserLine

func _ready() -> void:
  _on_maze_scale_changed()
  GameController.maze_scale_changed.connect(_on_maze_scale_changed)

func _on_maze_scale_changed()->void:
  var s:float = GameData.get_settings().maze_scale
  target_position = Vector2(0, -DISTANCE) / s

func _physics_process(_delta: float) -> void:
  if !is_active: return
  var cast_point := target_position
  #force_raycast_update()

  if is_colliding():
    var col = get_collider()
    if col.has_method('apply_damage'):
      col.apply_damage(damange)
    cast_point = to_local(get_collision_point())
    $TargetParticles.emitting = is_active
    $TargetParticles.position = cast_point
  else:
    $TargetParticles.emitting = false

  $LaserLine.points[1] = cast_point
  $LaserParticles.position = cast_point*0.5
  $LaserParticles.process_material.emission_box_extents.y = cast_point.length()*0.5

func set_active(v:bool)->void:
  if is_active == v: return
  is_active = v
  set_physics_process(is_active)
  $CastParticles.restart()
  $CastParticles.emitting = is_active
  $LaserParticles.restart()
  $LaserParticles.emitting = is_active
  $TargetParticles.restart()
  $TargetParticles.emitting = is_active

  $LaserLine.visible = is_active
