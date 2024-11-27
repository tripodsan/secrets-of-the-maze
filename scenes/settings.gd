class_name SettingsPanel
extends VBoxContainer

@onready var btn_controls: Button = %btn_controls
@onready var btn_scale: Button = %btn_scale

signal closed()

func _ready() -> void:
  update_scale()
  visible = false

func focus()->void:
  btn_controls.grab_focus()

func update_scale()->void:
  btn_scale.text = 'Level scale: %s' % GameData.get_settings().get_maze_scale_name()

func _on_btn_back_pressed() -> void:
  closed.emit()

func _on_btn_scale_pressed() -> void:
  GameData.get_settings().toggle_maze_scale()
  GameController.maze_scale_changed.emit()
  update_scale()
