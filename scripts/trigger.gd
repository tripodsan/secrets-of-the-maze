class_name Trigger
extends Node

## todo: generalize with 'activator' node
@export var target:SecretRoom

func _ready() -> void:
  get_parent().body_entered.connect(_on_body_entered)

func _on_body_entered(body:Node2D)->void:
  prints(body)
  if target:
    target.reveal()
    # todo: generalize
    get_parent().visible = false
