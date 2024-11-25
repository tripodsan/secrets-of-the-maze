extends Control

@onready var btn_resume_game: Button = %btn_resume_game
@onready var btn_restart_level: Button = %btn_restart_level
@onready var btn_exit_level: Button = %btn_exit_level

func _ready()->void:
  visible = false

func open()->void:
  visible = true
  btn_resume_game.grab_focus()

func close()->void:
  visible = false

func _on_btn_resume_game_pressed() -> void:
  close()
  GameController.resume_game()

func _on_btn_restart_level_pressed() -> void:
  pass # Replace with function body.

func _on_btn_exit_level_pressed() -> void:
  pass # Replace with function body.

func _unhandled_key_input(event: InputEvent) -> void:
  if event.is_action_pressed('pause'):
    open()
    GameController.pause_game()
