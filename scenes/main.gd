extends Node2D

@export var bg_color:Color = Color.BLACK

func _ready() -> void:
  RenderingServer.set_default_clear_color(bg_color)
