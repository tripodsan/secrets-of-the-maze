@tool
class_name SecretRoom
extends Node2D

@onready var animation: AnimationPlayer = $animation

@export var trigger:Trigger

signal secret_revealed(immediate:bool)

var id:int

var revealed:bool = false

#@export var transient:bool = false

func _ready():
  visible = false
  if Engine.is_editor_hint():
    animation.play("reveal", -1, 10000)

  id = int(name.split('_')[1])
  if trigger:
    trigger.activate.connect(reveal)
  prints('secret %d is ready' % id)

func reveal(immediate:bool = false)->void:
  if revealed:
    #print_debug('secret %d is already revealed (%s)' % [id, get_path()])
    return
  #print_debug('secret %d is revealed (%s)' % [id, get_path()])
  revealed = true
  if immediate:
    animation.play("reveal", -1, 10000)
  elif !visible:
    animation.play("reveal")
  secret_revealed.emit(immediate)
