extends Node

var scn_title:PackedScene = preload('res://scenes/title.tscn')
var scn_main:PackedScene = preload('res://scenes/main.tscn')
var scn_lvl_select:PackedScene = preload('res://scenes/level_map/level_select.tscn')

var _start_layer:GDLayer

var _current_layer:GDLayer

var player:Player

var level:Level

signal level_loaded(level:Level)

signal layer_activated(layer:ChromaLayer)

signal player_loaded(player:Player)

@warning_ignore('unused_signal')
signal portal_reached(p:Portal)

signal game_paused()

signal game_resumed()

signal blasted(blast:Blast)

@warning_ignore('unused_signal')
signal maze_scale_changed()

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
  _start_layer = layer
  await SceneTransition.change_scene(scn_main)

func activate_layer(layer:ChromaLayer)->void:
  _current_layer = layer.game_data
  layer_activated.emit(layer)

func on_game_scene_loaded(scn:GameScene)->void:
  print('gamecontroller: load_level')
  scn.load_level(_start_layer)

func on_level_state_change()->void:
  assert(level)
  if level.state == Level.State.READY:
    # level was just loaded, so start it
    level.start(_start_layer.type)
  elif level.state == Level.State.FINISHED:
    _start_layer.record_time(level.get_run_time())
    if _current_layer == _start_layer:
      GameData.unlock_next_level(_start_layer)
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
  level.picked_up_crystal(_current_layer.type, type)
  level.force_chroma_shift(type)

var _mouse_motion_timer:float = 0

func _unhandled_input(event: InputEvent) -> void:
  if event is InputEventMouse:
    _mouse_motion_timer = 0.0
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta:float)->void:
  if get_tree().paused: return
  if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
    _mouse_motion_timer += delta
    if _mouse_motion_timer > 3.0:
      Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func pause_game()->void:
  Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
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

var scn_blast:PackedScene = preload('res://entities/blast.tscn')
func create_blast(pos:Vector2, amount:float, radius:float, affect_player:bool = true, affect_enemy:bool = false):
  var blast:Blast = scn_blast.instantiate()
  blast.amount = amount
  blast.radius = radius
  blast.affect_player = affect_player
  blast.affect_enemy = affect_enemy
  blast.global_position = pos
  level.add_blast.call_deferred(blast)
  blasted.emit(blast)
