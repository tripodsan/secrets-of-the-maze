extends AudioStreamPlayer

func _ready() -> void:
  GameController.level_loaded.connect(_on_level_loaded)

func _on_level_loaded(level:Level)->void:
  level.state_changed.connect(_on_level_state_changed.bind(level))

func _on_level_state_changed(level:Level)->void:
  if level.state == Level.State.STARTED:
    if !playing:
      volume_db = 0
      play()
  elif level.state == Level.State.FINISHED:
    fade_out()

func fade_out():
  var tween = create_tween()
  tween.tween_property(self, 'volume_db', -80, 0.5)
  tween.tween_callback(stop)
