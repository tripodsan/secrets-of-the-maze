@tool
class_name HealthBar
extends PanelContainer

@onready var bar: ColorRect = $bar

@export_range(0, 100.0, 1.0) var percent:float = 100.0:
  set(v):
    percent = v
    recalc()

@export var color:Color:
  set(v):
    color = v
    if bar: bar.color = v

func _ready():
  percent = 100.0
  bar.color = color
  item_rect_changed.connect(recalc)
  recalc()

func recalc():
  if bar:
    fit_child_in_rect(bar, Rect2(0, 0, size.x * (percent / 100.0), size.y))
