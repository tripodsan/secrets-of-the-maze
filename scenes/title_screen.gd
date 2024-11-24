extends Control

@onready var btn_start: Button = %btn_start
@onready var btn_controls: Button = %btn_controls
@onready var btn_settings: Button = %btn_settings

@onready var title: VBoxContainer = $MarginContainer/title
@onready var settings: VBoxContainer = $MarginContainer/settings

func _ready() -> void:
  btn_start.grab_focus()

func _on_btn_start_pressed() -> void:
  GameController.start_game()

func _on_btn_settings_pressed() -> void:
  transition(title, settings, btn_controls)

func _on_btn_credits_pressed() -> void:
  pass

func _on_btn_new_game_pressed() -> void:
  GameData.reset()
  GameController.start_game()

func _on_btn_quit_pressed() -> void:
  get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
  get_tree().quit()

func _on_btn_back_pressed() -> void:
  transition(settings, title, btn_settings)

func transition(from:Control, to:Control, focus:Control)->void:
  to.visible = true
  to.modulate.a = 0.0
  var tween:Tween = create_tween()
  tween.tween_property(to, 'modulate:a', 1.0, 0.5)
  tween.parallel().tween_property(from, 'modulate:a', 0.0, 0.5)
  await tween.finished
  focus.grab_focus()
  from.visible = false
