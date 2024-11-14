@tool
class_name LevelMapNode
extends Node2D

@onready var visuals:Array[Sprite2D] = [$blue, $red, $green]

@export var layer:Global.Layer = Global.Layer.Blue: set = set_layer

func _ready()->void:
  set_layer(layer)

func set_layer(v)->void:
  if visuals.is_empty(): return
  layer = v
  for i in range(3):
    visuals[i].visible = i == v
