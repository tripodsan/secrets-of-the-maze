@tool
class_name Portal
extends Node2D

enum Shape {Ring, Triangle, Star}

@export var shape:Shape = Shape.Ring:set = set_shape

func _ready() -> void:
  set_shape(shape)

func set_shape(s:Shape)->void:
  shape = s
  for n in get_children():
    n.visible = false
  if shape < get_child_count():
    get_child(shape).visible = true
