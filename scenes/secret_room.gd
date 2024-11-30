class_name SecretRoom
extends Node2D

@onready var animation: AnimationPlayer = $animation

@export var trigger:Trigger

signal secret_revealed(immediate:bool)

var id:int

var revealed:bool = false

func _ready():
  visible = false
  id = int(name.split('_')[1])
  if trigger:
    trigger.activate.connect(reveal)
  prints('secret %d is ready' % id)

func reveal(immediate:bool = false)->void:
  if revealed: return
  prints('secret %d is revealed' % id)
  revealed = true
  if immediate:
    animation.play("reveal", -1, 10000)
  elif !visible:
    animation.play("reveal")
  secret_revealed.emit(immediate)
