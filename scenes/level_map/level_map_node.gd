class_name LevelMapNode
extends AnimatedSprite2D

var title:String = ''
var suffix:String = ''

signal clicked()

@export var nb_top:LevelMapNode

@export var nb_right:LevelMapNode

@export var nb_bottom:LevelMapNode

@export var nb_left:LevelMapNode

@export var gd_level:GDLevel

@export var gd_layer:GDLayer


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
  if event is InputEventMouseButton and event.is_released():
    clicked.emit()
