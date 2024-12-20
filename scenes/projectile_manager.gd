class_name ProjectileManager
extends Node2D

var scn_projectile = preload("res://entities/projectile.tscn")

var scn_bomb = preload('res://entities/bomb.tscn')

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

func shoot_projectile(xform:Transform2D):
#func shoot_projectile(pos, direction, speed, type, lifespan):
  # position+transform.x*50.0, transform.x, 750.0, 0, 2.0
  var projectile:RigidBody2D = projectile_pool[current_index]
  projectile.lifespan = 4.0
  projectile.start(xform.origin + xform.x*50.0, xform.x * 750)
  current_index = (current_index + 1) % MAX_PROJECTILES
  SoundController.play_sfx('missile')

func launch_bomb(xform:Transform2D)->void:
  var bomb = scn_bomb.instantiate()
  add_child(bomb)
  bomb.initialize(xform.origin + xform.x*10.0, -xform.x * 100.0)
