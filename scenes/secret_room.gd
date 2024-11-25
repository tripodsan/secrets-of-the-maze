class_name SecretRoom
extends Node2D

@onready var animation: AnimationPlayer = $animation

signal secret_revealed(immediate:bool)

var id:int

var revealed:bool = false

func _ready():
  visible = false
  id = int(name.split('_')[1])

func reveal(immediate:bool = false)->void:
  revealed = true
  if immediate:
    animation.play("reveal", -1, 10000)
  elif !visible:
    animation.play("reveal")
  secret_revealed.emit(immediate)
