# GameData: Layer
class_name GDLayer
extends GDSerializable

@export var best_time:int = 0

@export var unlocked:bool = false

var idx:Global.Layer

func _ready() -> void:
  idx = Global.get_layer_from_string(name)
  assert(idx >= 0)

func get_level()->GDLevel:
  return get_parent().get_parent()

func reset()->void:
  unlocked = false
  best_time = 0.0

func record_time(time:int)->void:
  if best_time == 0 || time < best_time:
    best_time = time
