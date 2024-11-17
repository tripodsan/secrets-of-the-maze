## GameData for Levels
class_name GDLevel
extends GDSerializable

@export var unlocked:bool = false

var _layers:Array[GDLayer] = []

func _ready() -> void:
  for n in $layers.get_children():
    _layers.append(n)

func get_layers()->Array[GDLayer]:
  return _layers

func get_nr()->int:
  return int(str(name))
