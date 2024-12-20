# GameData: Layer
class_name GDLayer
extends GDSerializable

@export var best_times:Array[int] = [0, 0, 0]

@export var unlocked:bool = false

@export_flags('Blue', 'Red', 'Green') var crystals:int = 0

@export var secrets:int = 0:
  set(v):
    secrets = v
    num_secrets = 0
    while v > 0:
      if v % 2: num_secrets += 1
      v >>= 1

var num_secrets:int = 0

## todo: this should not be part of the gamedata
@export var max_secrets:int = 2

var type:Global.Layer

func _ready() -> void:
  type = Global.get_layer_from_string(name)
  assert(type >= 0)

func get_level()->GDLevel:
  return get_parent().get_parent()

## marks the crystal as found
func set_crystal(layer:Global.Layer)->void:
  crystals |= Global.LAYER_MASK[layer]

func has_crystal(layer:Global.Layer)->bool:
  return crystals & Global.LAYER_MASK[layer] != 0

## marks the secret as found
func set_secret(nr:int):
  secrets |= 2**nr
  prints('set_secret(%d) -> %d' % [nr, secrets])

func has_secret(nr:int)->bool:
  return secrets & 2**nr != 0

func reset()->void:
  unlocked = false
  best_times = [0, 0, 0]
  crystals = 0
  secrets = 0

func record_time(goal:Global.Layer, time:int)->void:
  if best_times[goal] == 0 || time < best_times[goal]:
    best_times[goal] = time
