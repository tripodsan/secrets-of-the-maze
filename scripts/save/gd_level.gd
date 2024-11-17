## GameData for Levels
class_name GDLevel
extends GDSerializable

@export var unlocked:bool = false

func get_layers()->Node:
  return $layers
