## GameData for Levels
class_name GDLevel
extends GDSerializable

var ROMAN:Array[String] = ['O', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X']

@export var unlocked:bool = false

var _layers:Array[GDLayer] = []

func _ready() -> void:
  for n in $layers.get_children():
    _layers.append(n)

func get_layers()->Array[GDLayer]:
  return _layers

func get_nr()->int:
  return int(str(name))

func get_title()->String:
  return 'D%s' % ROMAN[get_nr() + 1]

func reset()->void:
  unlocked = false
  super.reset()

func unlock()->void:
  unlocked = true
  _layers[0].unlocked = true
