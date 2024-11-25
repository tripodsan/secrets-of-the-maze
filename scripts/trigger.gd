class_name Trigger
extends Node

## todo: generalize with 'activator' node
@export var target:SecretRoom

func _ready() -> void:
  if target && target.visible:
    get_parent().visible = false
  elif target:
    get_parent().body_entered.connect(_on_body_entered)
    target.secret_revealed.connect(_on_target_revealed)

func _on_body_entered(body:Node2D)->void:
  target.reveal()

func _on_target_revealed(immediate:bool)->void:
  # todo: generalize
  get_parent().visible = false
