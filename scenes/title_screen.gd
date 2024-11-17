extends Control

@onready var btn_start: Button = $MarginContainer/VBoxContainer/btn_start

func _ready() -> void:
  btn_start.grab_focus()

func _on_btn_start_pressed() -> void:
  GameController.start_game()

func _on_btn_settings_pressed() -> void:
  pass

func _on_btn_credits_pressed() -> void:
  pass

func _on_btn_quit_pressed() -> void:
  get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
  get_tree().quit()
