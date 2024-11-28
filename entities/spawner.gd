class_name Spawner
extends Node2D

@onready var swarm_parent: Node2D = $swarm

@export var scn_entity:PackedScene

@export var swarm_size:int = 5

@export var spawn_delay:float = 0.7

@export var one_shot:bool = true

@export var trigger:Trigger

@export var pre_spawn:bool = false

var spawning:bool = false

var spawn_timer:float = 0

var num_spawned:int = 0

var type:Global.Layer

# last spawned entity. only useful for pre-spawned objects
var entity:Node2D

func reset()->void:
  prints('spawner reset', name)
  for n in swarm_parent.get_children():
    swarm_parent.remove_child(n)
    n.queue_free()
  type = Global.get_chroma_layer(self).type
  spawning = false
  num_spawned = 0
  spawn_timer = 0
  entity = null
  if pre_spawn:
    spawn.call_deferred()

func _ready() -> void:
  trigger.activate.connect(_on_trigger_activate)

func _on_trigger_activate() -> void:
  if pre_spawn:
    launch()
    return
  if spawning: return
  spawning = true
  spawn.call_deferred()
  spawn_timer = 0

func spawn()->void:
  entity = scn_entity.instantiate()
  entity.layer = type
  prints('spawing', entity)
  swarm_parent.add_child(entity)
  entity.global_position = global_position
  num_spawned += 1

func launch()->void:
  if is_instance_valid(entity):
    entity.set_target(GameController.player)
  else:
    prints('unable to launch. entity is not valid')


func _process(delta:float)->void:
  if !spawning || num_spawned >= swarm_size: return
  spawn_timer += delta
  if spawn_timer > spawn_delay:
    spawn_timer -= spawn_delay
    spawn()
