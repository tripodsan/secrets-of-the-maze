class_name Spawner
extends Node2D

var scn_entity:PackedScene = preload('res://entities/figther.tscn')
@onready var swarm_parent: Node2D = $swarm

@export var swarm_size:int = 5

@export var spawn_delay:float = 0.7

@export var one_shot:bool = true

var spawning:bool = false

var spawn_timer:float = 0

var num_spawned:int = 0

func reset()->void:
  for n in swarm_parent.get_children():
    swarm_parent.remove_child(n)
    n.queue_free()
  spawning = false
  num_spawned = 0
  spawn_timer = 0

func _on_detector_body_entered(body: Node2D) -> void:
  if not body is Player: return
  if spawning: return
  spawning = true
  spawn.call_deferred()
  spawn_timer = 0

func spawn()->void:
  var entity:Node2D = scn_entity.instantiate()
  prints('spawing', entity)
  swarm_parent.add_child(entity)
  entity.global_position = global_position
  num_spawned += 1

func _process(delta:float)->void:
  if !spawning || num_spawned >= swarm_size: return
  spawn_timer += delta
  if spawn_timer > spawn_delay:
    spawn_timer -= spawn_delay
    spawn()
