# GameData: Layer
class_name GDLayer
extends GDSerializable

@export var best_time:float = 0.0

@export var unlocked:bool = false

var idx:Global.Layer

func _ready() -> void:
  idx = Global.get_layer_from_string(name)
  assert(idx >= 0)

func get_level()->GDLevel:
  return get_parent().get_parent()
