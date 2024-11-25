extends Node

var scn_title:PackedScene = preload('res://scenes/title.tscn')
var scn_main:PackedScene = preload('res://scenes/main.tscn')
var scn_lvl_select:PackedScene = preload('res://scenes/level_map/level_select.tscn')

var _current_layer:GDLayer

var player:Player

var level:Level

signal level_loaded(level:Level)

signal player_loaded(player:Player)

signal portal_reached(p:Portal)

signal game_paused()

signal game_resumed()

func start_game()->void:
  show_level_select()

func show_level_select():
  level = null
  player = null
  SceneTransition.change_scene(scn_lvl_select)

func show_title_screen():
  SceneTransition.change_scene(scn_title)

## Starts the level with the given layer as starting point
## calls by the level select screeen
func start_level(layer:GDLayer)->void:
  print('gamecontroller: start_level')
  _current_layer = layer
  await SceneTransition.change_scene(scn_main)

func on_game_scene_loaded(scn:GameScene)->void:
  print('gamecontroller: load_level')
  scn.load_level(_current_layer)

func on_level_state_change()->void:
  assert(level)
  if level.state == Level.State.READY:
    # level was just loaded, so start it
    level.start(_current_layer.type)
  elif level.state == Level.State.FINISHED:
    _current_layer.record_time(level.get_run_time())
    GameData.unlock_next_level(_current_layer.get_level())
    show_level_select()

func set_player(p:Player)->void:
  player = p
  player_loaded.emit(p)

func get_player_deferred(cb)->void:
  if player:
    cb.call(player)
  else:
    player_loaded.connect(cb, CONNECT_ONE_SHOT)

func set_level(l:Level)->void:
  level = l
  level_loaded.emit(l)
  level.state_changed.connect(on_level_state_change)

func on_chroma_crystal_pickup(type:Global.Layer)->void:
  level.force_chroma_shift(type)
  _current_layer.set_crystal(type)
  _current_layer.get_level().get_layers()[type].unlocked = true

var _mouse_motion_timer:float = 0

func _unhandled_input(event: InputEvent) -> void:
  if event is InputEventMouse:
    _mouse_motion_timer = 0.0
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta:float)->void:
  if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
    _mouse_motion_timer += delta
    if _mouse_motion_timer > 3.0:
      Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func pause_game()->void:
  get_tree().paused = true
  game_paused.emit()

func resume_game()->void:
  get_tree().paused = false
  game_resumed.emit()

func restart_level()->void:
  resume_game()
  level.restart()

func exit_level()->void:
  resume_game()
  level.quit()
  show_level_select()
