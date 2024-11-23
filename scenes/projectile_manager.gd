class_name ProjectileManager
extends Node2D

var scn_projectile = preload("res://scenes/projectile.tscn")

const MAX_PROJECTILES = 100
var projectile_pool = []
var current_index := 0

func _ready() -> void:
  # initialze projectile pool
  for i in range(MAX_PROJECTILES):
    var projectile = scn_projectile.instantiate()
    projectile.visible = false
    add_child(projectile)
    projectile_pool.append(projectile)


func shoot_projectile(pos, direction, speed, type, lifespan):
  var projectile:RigidBody2D = projectile_pool[current_index]
  projectile.type = type
  projectile.lifespan = 4.0
  projectile.start(pos, direction.normalized() * speed)

  current_index = (current_index + 1) % MAX_PROJECTILES
