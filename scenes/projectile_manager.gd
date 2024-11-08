extends Node2D

const MAX_PROJECTILES = 20
var projectile_pool = []
var current_index := 0

func _ready() -> void:
  # initialze projectile pool
  for i in range(MAX_PROJECTILES):
    var projectile = preload("res://scenes/projectile.tscn").instantiate()
    projectile.visible = false
    add_child(projectile)
    projectile_pool.append(projectile)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func shoot_projectile(pos, direction, speed, type, lifespan):
  var projectile = projectile_pool[current_index]
  
  projectile.global_position = pos
  projectile.direction = direction.normalized()
  projectile.speed = speed
  projectile.type = type
  projectile.lifespan = lifespan
  projectile.time_alive = 0.0
  projectile.start()
  
  current_index = (current_index + 1) % MAX_PROJECTILES  
