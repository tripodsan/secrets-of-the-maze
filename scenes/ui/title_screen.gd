extends Control

@onready var btn_start: Button = %btn_start
@onready var btn_settings: Button = %btn_settings

@onready var title: VBoxContainer = $MarginContainer/title
@onready var settings: SettingsPanel = $MarginContainer/settings
@onready var controls: KeyboardBindings = $MarginContainer/controls

func _ready() -> void:
  btn_start.grab_focus()
  settings.closed.connect(_on_settings_closed)
  controls.closed.connect(_on_controls_closed)
  # todo..move to game data?
  KeyboardBindings.load_settings()

func _on_btn_start_pressed() -> void:
  GameController.start_game()

func _on_btn_settings_pressed() -> void:
  transition(title, settings)

func _on_btn_controls_pressed() -> void:
  transition(title, controls)

func _on_btn_credits_pressed() -> void:
  pass

func _on_btn_new_game_pressed() -> void:
  GameData.reset()
  GameController.start_game()

func _on_btn_quit_pressed() -> void:
  get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
  get_tree().quit()

func _on_settings_closed() -> void:
  await transition(settings, title)
  btn_start.grab_focus()

func _on_controls_closed() -> void:
  await transition(controls, title)
  btn_start.grab_focus()

func transition(from:Control, to:Control)->void:
  to.visible = true
  to.modulate.a = 0.0
  var tween:Tween = create_tween()
  tween.tween_property(to, 'modulate:a', 1.0, 0.5)
  tween.parallel().tween_property(from, 'modulate:a', 0.0, 0.5)
  await tween.finished
  if to.has_method('focus'):
    to.focus()
  from.visible = false
