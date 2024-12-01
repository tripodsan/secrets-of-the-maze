class_name CreditsPanel
extends MarginContainer

signal closed()

@onready var btn_back: Button = $VBoxContainer/btn_back

func _ready() -> void:
  visible = false

func focus()->void:
  btn_back.grab_focus()

func _on_btn_back_pressed() -> void:
  closed.emit()
