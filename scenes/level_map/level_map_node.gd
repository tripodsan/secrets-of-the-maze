class_name LevelMapNode
extends AnimatedSprite2D

var title:String = ''
var suffix:String = ''

signal clicked()

static var DIRS = [
  Vector2i(0, -1),
  Vector2i(1, 0),
  Vector2i(0, 1),
  Vector2i(-1, 0),
]

var neighbors:Array[LevelMapNode] = [null, null, null, null]

var gd_level:GDLevel

var gd_layer:GDLayer

func get_nb_bitmask()->int:
  var msk:int = 0
  for i in range(4):
    if neighbors[i]: msk += 2**i
  return msk

@warning_ignore('unused_parameter')
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
  if event is InputEventMouseButton and event.is_released():
    clicked.emit()
