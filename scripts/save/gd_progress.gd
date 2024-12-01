class_name GDProgress
extends GDSerializable

@export var modified:bool = false

func reset()->void:
  modified = false

func touch()->void:
  modified = true
