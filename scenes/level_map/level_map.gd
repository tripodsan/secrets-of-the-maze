class_name LevelMap
extends Node2D

@onready var cursor: LevelMapCursor = $cursor

@export var selected_level:LevelMapNode

func _input(event: InputEvent) -> void:
  if Input.is_action_just_pressed('ui_left'):
    select(selected_level.nb_left)
  elif Input.is_action_just_pressed('ui_right'):
    select(selected_level.nb_right)
  elif Input.is_action_just_pressed('ui_up'):
    select(selected_level.nb_top)
  elif Input.is_action_just_pressed('ui_down'):
    select(selected_level.nb_bottom)

func select(next:LevelMapNode):
  if !next: return
  selected_level = next
  cursor.position = next.position
  cursor.set_opening_by_direction(!!next.nb_top, !!next.nb_right, !!next.nb_bottom, !!next.nb_left)
