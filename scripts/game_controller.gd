extends Node

var scn_title:PackedScene = preload('res://scenes/title.tscn')
var scn_main:PackedScene = preload('res://scenes/main.tscn')
var scn_lvl_select:PackedScene = preload('res://scenes/level_map/level_select.tscn')

var _current_layer:GDLayer

func start_game()->void:
  SceneTransition.change_scene(scn_lvl_select)

func start_level(layer:GDLayer)->void:
  _current_layer = layer
  SceneTransition.change_scene(scn_main)

func on_game_sceene_loaded(main:GameScene):
  main.start_level(_current_layer)
