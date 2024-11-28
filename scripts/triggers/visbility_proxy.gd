class_name VisibilityProxy
extends Node

@export var source:Node2D

@export var invert:bool = false

func _ready() -> void:
  source.visibility_changed.connect(_on_visibility_changed)
  _on_visibility_changed()

func _on_visibility_changed()->void:
  get_parent().visible = not source.visible if invert else source.visible
