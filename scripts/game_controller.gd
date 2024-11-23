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

func start_game()->void:
  SceneTransition.change_scene(scn_lvl_select)

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
    level.start(_current_layer.idx)


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
