extends AudioStreamPlayer

func _ready() -> void:
  GameController.level_loaded.connect(_on_level_loaded)
  GameController.game_paused.connect(_on_game_paused)
  GameController.game_resumed.connect(_on_game_resumed)

func _on_level_loaded(level:Level)->void:
  level.state_changed.connect(_on_level_state_changed.bind(level))

func _on_level_state_changed(level:Level)->void:
  if level.state == Level.State.STARTED:
    if !playing:
      volume_db = 0
      play()
      get_stream_playback().switch_to_clip(level.nr)
  elif level.state == Level.State.FINISHED:
    fade_out()

func fade_out():
  await change_volume(-80, 1.0)
  stop()

func _on_game_paused()->void:
  change_volume(-20)

func _on_game_resumed()->void:
  change_volume(0)

func change_volume(db:float, time:float = 0.5)->void:
  var tween = create_tween()
  tween.tween_property(self, 'volume_db', db, time)
  await tween.finished
