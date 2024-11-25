@tool
class_name ChromaCrystal
extends Node2D

@onready var shape:CubeProjection = $shape

@export var type:Global.Layer = Global.Layer.RED: set = set_type

var COLORS = [
  {
    "border": Color("09ccec"),
    "fill": Color("096aecaa")
  },
  {
    "border": Color("ff881a"),
    "fill": Color('a23000aa')
  },
  {
    "border": Color("9aeb00"),
    "fill": Color('386900a0')
  },
]

func _ready()->void:
  set_type(type)

func _on_detector_body_entered(body: Node2D) -> void:
  if body is Player:
    body.pickup(self)

func set_type(v):
  type = v
  if shape:
    shape.line_color = COLORS[type].border
    shape.fill_color = COLORS[type].fill