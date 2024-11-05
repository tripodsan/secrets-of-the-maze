extends RayCast2D


var is_casting := false 


func _process(delta: float) -> void:
  pass

func _physics_process(delta: float) -> void:
  var cast_point := target_position
  force_raycast_update()
  
  if is_colliding():
    cast_point = to_local(get_collision_point())
       
  $TargetParticles.position = cast_point
  $LaserLine.points[1] = cast_point
  $LaserParticles.position = cast_point*0.5
  $LaserParticles.process_material.emission_box_extents.y = cast_point.length()*0.5

func set_is_casting(cast):
  is_casting = cast
  set_physics_process(is_casting)
  $CastParticles.emitting = is_casting
  $TargetParticles.emitting = is_casting  
  $LaserParticles.emitting = is_casting
  $LaserLine.visible = is_casting
