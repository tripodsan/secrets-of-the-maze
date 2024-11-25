# GameData: Layer
class_name GDLayer
extends GDSerializable

@export var best_time:int = 0

@export var unlocked:bool = false

@export var crystals:int = 0

var type:Global.Layer

func _ready() -> void:
  type = Global.get_layer_from_string(name)
  assert(type >= 0)

func get_level()->GDLevel:
  return get_parent().get_parent()

func set_crystal(layer:Global.Layer)->void:
  crystals |= Global.LAYER_MASK[layer]

func has_crystal(layer:Global.Layer)->bool:
  return crystals & Global.LAYER_MASK[layer] != 0

func reset()->void:
  unlocked = false
  best_time = 0.0
  crystals = 0

func record_time(time:int)->void:
  if best_time == 0 || time < best_time:
    best_time = time
