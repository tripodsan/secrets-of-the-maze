class_name SecretRoom
extends Node2D

@onready var animation: AnimationPlayer = $animation

func _ready():
  visible = false

func reveal()->void:
  if !visible:
    animation.play("reveal")
