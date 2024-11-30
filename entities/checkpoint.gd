class_name Checkpoint
extends Area2D

var time:float

func _ready() -> void:
  $helper_arrow.visible = false

func _on_body_entered(body: Node2D) -> void:
  GameController.checkpoint_reached(self)
