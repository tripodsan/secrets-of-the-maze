extends Control

@onready var btn_resume_game: Button = %btn_resume_game
@onready var btn_restart_level: Button = %btn_restart_level
@onready var btn_exit_level: Button = %btn_exit_level

@onready var pause_menu: VBoxContainer = %pause_menu
@onready var settings_menu: SettingsPanel = %settings_menu

func _ready()->void:
  visible = false
  settings_menu.closed.connect(_on_settings_closed)

func open()->void:
  visible = true
  pause_menu.visible = true
  settings_menu.visible = false
  btn_resume_game.grab_focus()

func close()->void:
  visible = false

func _on_btn_resume_game_pressed() -> void:
  close()
  GameController.resume_game()

func _on_btn_restart_level_pressed() -> void:
  close()
  GameController.restart_level()

func _on_btn_exit_level_pressed() -> void:
  close()
  GameController.exit_level()

func _unhandled_key_input(event: InputEvent) -> void:
  if event.is_action_pressed('pause'):
    open()
    GameController.pause_game()

func _on_btn_setting_pressed() -> void:
  transition(pause_menu, settings_menu)

func _on_settings_closed()->void:
  await transition(settings_menu, pause_menu)
  btn_resume_game.grab_focus()

func transition(from:Control, to:Control)->void:
  to.visible = true
  to.modulate.a = 0.0
  var tween:Tween = create_tween()
  tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
  tween.tween_property(to, 'modulate:a', 1.0, 0.5)
  tween.parallel().tween_property(from, 'modulate:a', 0.0, 0.5)
  await tween.finished
  if to.has_method('focus'):
    to.focus()
  from.visible = false
