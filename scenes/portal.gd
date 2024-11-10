@tool
class_name Portal
extends Node2D

enum Shape {Ring, Triangle, Star}

var _colors:Array[GradientTexture1D] = [
  preload('res://scenes/gradient_texture_green_to_red.tres'), # blue layer
  preload('res://scenes/gradient_texture_blue_to_green.tres'), # red layer
  preload('res://scenes/gradient_texture_blue_to_red.tres') # green layer
]

@export var shape:Shape = Shape.Ring:set = set_shape

@export var layer:Global.Layer = Global.Layer.Blue:set = set_layer

func _ready() -> void:
  set_shape(shape)
  set_layer(layer)

func set_shape(s:Shape)->void:
  shape = s
  for n in get_children():
    n.visible = false
    n.emitting = false
  if shape < get_child_count():
    get_child(shape).visible = true
    get_child(shape).restart()

func set_layer(l)->void:
  layer = l
  if shape < get_child_count():
    get_child(shape).process_material.color_ramp = _colors[layer]
    get_child(shape).restart()
