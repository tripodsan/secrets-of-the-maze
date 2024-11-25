class_name SettingsPanel
extends VBoxContainer

@onready var btn_controls: Button = %btn_controls

signal closed()

func focus()->void:
  btn_controls.grab_focus()

func _on_btn_back_pressed() -> void:
  closed.emit()
