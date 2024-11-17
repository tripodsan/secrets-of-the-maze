extends Node

var scn_title:PackedScene = preload('res://scenes/title.tscn')
var scn_main:PackedScene = preload('res://scenes/main.tscn')

func start_game()->void:
  SceneTransition.change_scene(scn_main)

func on_game_sceene_loaded(main:GameScene):
  main.start_level(GameData.get_layer(0, Global.Layer.BLUE))
